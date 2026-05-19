module "vpc" {
  source = "./modules/vpc"

  vpc_name         = var.vpc_name
  region           = var.region
  enable_flow_logs = var.enable_soc2_compliance
  enable_cloud_nat = var.enable_soc2_compliance || var.enable_cloud_nat
}

module "firewall" {
  source = "./modules/firewall"

  network_name = module.vpc.network_name
}
