#!/bin/bash

# Delete Argo related CRDs
kubectl delete crd applications.argoproj.io \
                   applicationsets.argoproj.io \
                   appprojects.argoproj.io

# Delete Cert-Manager related CRDs
kubectl delete crd certificaterequests.cert-manager.io \
                   certificates.cert-manager.io \
                   challenges.acme.cert-manager.io \
                   clusterissuers.cert-manager.io \
                   issuers.cert-manager.io \
                   orders.acme.cert-manager.io

# Delete namespaces no longer needed
kubectl delete namespace argocd
kubectl delete namespace cert-manager
kubectl delete namespace external-dns
kubectl delete namespace ingress-nginx

# Delete Helm releases
helm uninstall argocd -n argocd
helm uninstall cert-manager -n cert-manager
helm uninstall external-dns -n external-dns
helm uninstall ingress-nginx -n ingress-nginx
