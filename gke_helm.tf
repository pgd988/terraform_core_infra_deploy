# This file is reserved for defining Helm releases for your GKE cluster.
# You can conditionally deploy charts here leveraging the "enable_helm" flag.

/*
resource "helm_release" "example_nginx" {
  count      = var.enable_gke && var.enable_helm ? 1 : 0
  
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  
  namespace  = var.app_namespace
  
  # Ensure the namespace exists before deploying
  depends_on = [kubernetes_namespace.app_ns]
}
*/
