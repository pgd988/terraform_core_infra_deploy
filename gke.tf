module "gke_cluster" {
  source = "./modules/gke_cluster"

  create_cluster                = var.enable_gke
  project_id                    = var.project_id
  region                        = var.region
  zone                          = var.zone
  cluster_name                  = var.gke_cluster_name
  network_id                    = module.vpc.network_id
  subnetwork_id                 = module.vpc.subnetwork_id
  cluster_secondary_range_name  = module.vpc.pod_secondary_range_name
  services_secondary_range_name = module.vpc.service_secondary_range_name
  main_domain                   = var.main_domain
  enable_workload_identity      = var.enable_workload_identity
  resource_labels               = local.common_labels

  kms_key_name              = var.enable_soc2_compliance ? google_kms_crypto_key.soc2_key[0].id : ""
  enable_confidential_nodes = var.enable_soc2_compliance

  default_pool_min_count    = var.gke_default_pool_min_count
  default_pool_max_count    = var.gke_default_pool_max_count
  default_pool_machine_type = var.enable_soc2_compliance ? "n2d-standard-2" : var.gke_default_pool_machine_type
  default_pool_disk_size    = var.gke_default_pool_disk_size
  default_pool_env_label    = var.gke_default_pool_env_label

  apps_pool_min_count    = var.gke_apps_pool_min_count
  apps_pool_max_count    = var.gke_apps_pool_max_count
  apps_pool_machine_type = var.enable_soc2_compliance ? "n2d-standard-2" : var.gke_apps_pool_machine_type
  apps_pool_disk_size    = var.gke_apps_pool_disk_size
  apps_pool_env_label    = var.gke_apps_pool_env_label
}
