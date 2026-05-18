module "gke_internals" {
  source = "./modules/gke_internals"

  enable_internals     = var.enable_gke && var.enable_gke_internals
  enable_argocd        = var.enable_argocd
  app_namespace        = var.app_namespace
  argocd_ssh_key_ready = var.argocd_ssh_key_ready
  argocd_git_repo_url  = var.argocd_git_repo_url
  labels               = local.common_labels

  depends_on = [module.gke_cluster]
}
