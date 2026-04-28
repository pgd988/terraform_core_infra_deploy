# This file is reserved for defining Helm releases for your GKE cluster.
# You can conditionally deploy charts here leveraging the "enable_helm" flag.

resource "helm_release" "ingress_nginx_default" {
  count = var.enable_gke && var.enable_helm ? 1 : 0

  name  = "ingress-nginx-default"
  chart = "./helm/default-ingress-nginx"

  namespace = var.app_namespace

  # Ensure the namespace exists before deploying
  depends_on = [kubernetes_namespace.app_ns]
}

resource "helm_release" "argocd" {
  count = var.enable_gke && var.enable_helm && var.enable_argocd ? 1 : 0

  name       = "argocd"
  chart      = "./helm/argocd"
  namespace  = kubernetes_namespace.argocd_ns[0].metadata[0].name
  depends_on = [kubernetes_namespace.argocd_ns]
}

resource "helm_release" "argo_rollouts" {
  count = var.enable_gke && var.enable_helm && var.enable_argocd ? 1 : 0

  name       = "argo-rollouts"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-rollouts"
  namespace  = kubernetes_namespace.argo_rollouts_ns[0].metadata[0].name
  depends_on = [kubernetes_namespace.argo_rollouts_ns]
}

