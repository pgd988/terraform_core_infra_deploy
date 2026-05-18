module "gke_helm" {
  source = "./modules/gke_helm"

  enable_helm             = var.enable_gke && var.enable_helm
  enable_argocd           = var.enable_argocd && var.enable_gke_internals
  app_namespace           = var.app_namespace
  argocd_namespace        = "argocd"
  argo_rollouts_namespace = "argo-rollouts"
  argocd_git_repo_url     = var.argocd_git_repo_url
  argocd_ssh_key_ready    = var.argocd_ssh_key_ready
  main_domain             = var.main_domain

  depends_on = [module.gke_internals]
}
