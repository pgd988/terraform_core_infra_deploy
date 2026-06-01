module "kyverno" {
  source = "./modules/kyverno"

  enable_kyverno = var.enable_gke && var.enable_kyverno
  kyverno_mode   = var.kyverno_mode

  depends_on = [module.gke_cluster]
}
