resource "helm_release" "nginx" {
  name             = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  version          = "4.15.1"
  create_namespace = true
  namespace        = "ingress-nginx"
}

resource "helm_release" "cert_manager" {
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  create_namespace = true
  namespace        = "cert-manager"

  set = [
    {
      name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
      value = module.cert_manager_irsa_role.iam_role_arn
    }
  ]

  values = [file("helm-values/cert-manager.yaml")]
}

resource "helm_release" "external_dns" {
  name             = "external-dns"
  repository       = "https://kubernetes-sigs.github.io/external-dns/"
  chart            = "external-dns"
  version          = "1.23.0"
  create_namespace = true
  namespace        = "external-dns"

  set = [
    {
      name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
      value = module.external_dns_irsa_role.iam_role_arn
    }
  ]

  values = [file("helm-values/external-dns.yaml")]
}