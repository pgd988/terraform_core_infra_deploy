module "load_balancer" {
  source = "./modules/load_balancer"

  create_lb            = var.enable_lb && var.enable_gke && var.enable_gke_internals
  enable_helm          = var.enable_helm
  enable_argocd        = var.enable_argocd
  zone                 = var.zone
  lb_cert_trigger      = var.lb_cert_trigger
  lb_health_check_port = var.lb_health_check_port

  # RabbitMQ UI Routing Configuration
  enable_rmq_vm      = var.enable_rmq_vm
  rmq_instance_group = var.enable_rmq_vm ? google_compute_instance_group.rabbitmq_production[0].id : null
  rmq_admin_domain   = var.rmq_admin_domain
  rmq_admin_port     = var.rmq_admin_port

  depends_on = [module.gke_helm, module.gke_internals]
}
