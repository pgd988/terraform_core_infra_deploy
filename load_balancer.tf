module "load_balancer" {
  source = "./modules/load_balancer"

  create_lb            = var.enable_lb && var.enable_gke && var.enable_gke_internals
  enable_helm          = var.enable_helm
  enable_argocd        = var.enable_argocd
  zone                 = var.zone
  lb_cert_trigger      = var.lb_cert_trigger
  lb_health_check_port = var.lb_health_check_port

  depends_on = [module.gke_helm, module.gke_internals]
}
