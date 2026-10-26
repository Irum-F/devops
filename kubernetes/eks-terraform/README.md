# EKS Lab: Terraform, Ingress, cert-manager and ExternalDNS

Provisions an Amazon EKS cluster with Terraform and exposes apps over HTTPS on a custom domain, with DNS records and TLS certificates created automatically.

Built as Project 1 (Terraform + Kubernetes)

## Architecture

                        +------------------------+
                        |          User          |
                        +-----------+------------+
                                    |
                                    | https://app.lab.irum.dev
                                    v
+--------------------+   NS    +------------------------+
|     Cloudflare     |-------->|        Route 53        |
|      irum.dev      | delegate|      lab.irum.dev      |
+--------------------+         +-----------+------------+
                                    ^       |
              A / TXT records       |       v
       +----------------------------+  +----------------------+
       |       DNS-01 challenge     |  |  AWS Load Balancer   |
       |                            |  +----------+-----------+
       |                            |             |
+------+----------------------------+-------------v---------------+
|                         EKS cluster                              |
|                                                                  |
|  +--------------+   +----------------+   +--------------------+  |
|  | ExternalDNS  |   |  cert-manager  |   |   ingress-nginx    |  |
|  +--------------+   +-------+--------+   +---------+----------+  |
|                             |                      |             |
|                             |                      v             |
|                             |            +--------------------+  |
|                             |            |      App pods      |  |
|                             |            +--------------------+  |
+-----------------------------+------------------------------------+
                              |
                              v
                     +------------------+
                     |  Let's Encrypt   |
                     +------------------+

## What it does

- **VPC** across multiple Availability Zones with public and private subnets and a NAT gateway
- **EKS cluster** with a managed node group and IRSA enabled
- **ingress-nginx** as the ingress controller, exposed through an AWS load balancer
- **ExternalDNS** watches Ingress resources and creates matching records in Route 53
- **cert-manager** issues Let's Encrypt certificates using the DNS-01 challenge on Route 53
- **IRSA** gives ExternalDNS and cert-manager their own IAM roles scoped to Route 53, so no static AWS keys exist anywhere in the cluster

## Tech stack

| Component                                    | Version             |
| -------------------------------------------- | ------------------- |
| `terraform-aws-modules/vpc/aws`              | 5.9.0               |
| `terraform-aws-modules/eks/aws`              | ~> 20.0             |
| `terraform-aws-modules/iam/aws` (IRSA roles) | 5.2.0               |
| AWS provider                                 | ~> 5.0              |
| Helm provider                                | ~> 3.0              |
| ingress-nginx chart                          | 4.15.1              |
| cert-manager chart                           | pinned in `helm.tf` |
| external-dns chart                           | pinned in `helm.tf` |

Every module, provider and chart is pinned. See [Problems I hit](#problems-i-hit-and-how-i-fixed-them) for why.

## Repository structure

```
.
├── providers.tf        # AWS, Helm and Kubernetes providers
├── locals.tf           # names and tags
├── vpc.tf              # VPC, subnets, NAT gateway
├── eks.tf              # EKS cluster and managed node group
├── irsa.tf             # IAM roles for cert-manager and ExternalDNS
├── helm.tf             # ingress-nginx, cert-manager, ExternalDNS
└── helm-values/
    ├── cert-manager.yaml
    └── external-dns.yaml
```

## Prerequisites

- An AWS account and the AWS CLI v2, configured (`aws sts get-caller-identity` works)
- Terraform, `kubectl` and `helm`
- A domain you control. Here, `lab.irum.dev` is a Route 53 hosted zone delegated from Cloudflare, which hosts `irum.dev`.

## DNS setup (one time)

1. Create a public hosted zone for the subdomain (e.g. `lab.irum.dev`) in Route 53.
2. Copy the hosted zone's four NS records into the parent domain's DNS provider as NS records for the subdomain.
3. Verify the delegation by asking one of the AWS name servers directly:

   ```bash
   dig @<one-of-the-awsdns-servers> lab.irum.dev SOA
   ```

   `status: NOERROR` means the delegation works. `REFUSED` means the NS records don't match the hosted zone.

> If the hosted zone is ever deleted and recreated, AWS assigns new name servers and the NS records in the parent domain must be updated.

## Deploy

```bash
terraform init
terraform plan
terraform apply

aws eks update-kubeconfig --name eks-lab --region <region>
kubectl get pods -A
```

Then create the Let's Encrypt `ClusterIssuer` (start with the staging server to avoid rate limits):

```yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: issuer
spec:
  acme:
    server: https://acme-staging-v02.api.letsencrypt.org/directory
    email: <your-email>
    privateKeySecretRef:
      name: issuer-account-key
    solvers:
      - selector:
          dnsZones:
            - lab.irum.dev
        dns01:
          route53:
            region: <region>
```

## Exposing an app

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: app
  annotations:
    cert-manager.io/cluster-issuer: issuer
spec:
  ingressClassName: nginx
  tls:
    - hosts:
        - app.lab.irum.dev
      secretName: app-tls
  rules:
    - host: app.lab.irum.dev
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: app
                port:
                  number: 80
```

Applying this Ingress triggers the whole chain: ExternalDNS creates the DNS record, cert-manager proves domain ownership with a DNS-01 TXT record and stores the certificate in `app-tls`, and ingress-nginx serves the app over HTTPS.

## Verify

```bash
kubectl get certificate -A                         # READY should be True
kubectl logs -n external-dns deploy/external-dns   # look for created records
kubectl logs -n cert-manager deploy/cert-manager
dig app.lab.irum.dev
```

Once a staging certificate shows `READY: True`, switch the issuer's server to `https://acme-v02.api.letsencrypt.org/directory`.

## Tear down

```bash
terraform destroy
```

> **Cost warning:** the EKS control plane, worker nodes, NAT gateway and load balancer are all billed by the hour. Destroy the stack after every session.

If `destroy` hangs on subnets or the VPC, a load balancer created by Kubernetes is usually still attached. Check the EC2 > Load Balancers console, delete it, and run `destroy` again.

## Problems I hit and how I fixed them

The original tutorial code was written for older versions, and every unpinned dependency had since released a breaking change.

| Problem | Cause | Fix |
| --- | --- | --- |
| `An argument named "cluster_name" is not expected here` | EKS module v21 renamed most inputs; the module wasn't pinned | Pinned the EKS module to `~> 20.0` |
| `Unreadable module subdirectory iam-role-for-service-accounts-eks` | IAM module v6 removed that submodule | Pinned the IAM module to `5.2.0` |
| `unsupported Kubernetes version 1.23` | EKS no longer creates clusters on 1.23 | Used a version in standard support (`aws eks describe-cluster-versions`) |
| `Blocks of type "set" are not expected here` | Helm provider v3 changed `set`, `kubernetes` and `exec` from blocks to attributes | Switched to `set = [{ ... }]` syntax and pinned the provider to `~> 3.0` |
| cert-manager: `values don't meet the specifications of the schema` | `ingressShim.defaultACMEChallengeType` and `defaultACMEDNS01ChallengeProvider` were removed | Moved the DNS-01/Route 53 config into the `ClusterIssuer` solvers |
| Bitnami chart repository timed out | Bitnami restricted its free charts and images | Switched to the official ingress-nginx and external-dns charts |
| `server can't find lab.irum.dev: SERVFAIL` | Subdomain delegation to Route 53 not resolving | Checked the hosted zone's NS records against the parent domain and queried the AWS name servers directly |

**Main lesson:** pin every module, provider and Helm chart version. Unpinned code that works today breaks on the next major release.

## Security notes

- No static AWS credentials: cert-manager and ExternalDNS authenticate through IRSA.
- IAM role ARNs are passed from Terraform outputs, not hardcoded in values files.
- Limit Kubernetes API access with `cluster_endpoint_public_access_cidrs` set to your own IP.
- Terraform state, `.tfvars` files and kubeconfigs are excluded from Git (see `.gitignore`).

## What I'd improve next

- Remote Terraform state in S3 with state locking
- Migrate from ingress-nginx (now retired) to the Gateway API
- Deploy apps with GitOps using Argo CD
- Add Prometheus and Grafana for monitoring