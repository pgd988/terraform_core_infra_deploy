module "vpc" {
  source = "./modules/vpc"

  vpc_name = var.vpc_name
  region   = var.region
}

module "firewall" {
  source = "./modules/firewall"

  network_name = module.vpc.network_name
}
