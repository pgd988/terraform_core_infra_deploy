# --- App VM ---
module "app_vm" {
  source = "./modules/compute_vm"

  create_vm       = var.enable_app_vm && !var.enable_soc2_compliance
  name            = "app-vm"
  machine_type    = var.enable_soc2_compliance ? "n2d-standard-2" : var.vm_types["app"]
  zone            = var.zone
  region          = var.region
  subnetwork_id   = module.vpc.subnetwork_id
  boot_disk_image = var.ubuntu_image
  boot_disk_size  = var.vm_boot_disk_sizes["app"]
  ip_type         = "EXTERNAL_STATIC"
  tags            = ["ssh-allow", "app"]
  labels = merge(local.common_labels, {
    role = "app"
  })
  kms_key_name                = var.enable_soc2_compliance ? google_kms_crypto_key.soc2_key[0].id : ""
  enable_confidential_compute = var.enable_soc2_compliance
  enable_oslogin              = var.enable_soc2_compliance
}

# --- DB VM ---
module "db_vm" {
  source = "./modules/compute_vm"

  create_vm       = var.enable_db_vm
  name            = "db-vm"
  machine_type    = var.enable_soc2_compliance ? "n2d-standard-2" : var.vm_types["db"]
  zone            = var.zone
  region          = var.region
  subnetwork_id   = module.vpc.subnetwork_id
  boot_disk_image = var.ubuntu_image
  boot_disk_size  = var.vm_boot_disk_sizes["db"]
  ip_type         = "INTERNAL_STATIC"
  tags            = ["ssh-allow", "db"]
  labels = merge(local.common_labels, {
    role = "db"
  })
  kms_key_name                = var.enable_soc2_compliance ? google_kms_crypto_key.soc2_key[0].id : ""
  enable_confidential_compute = var.enable_soc2_compliance
  enable_oslogin              = var.enable_soc2_compliance
}

# --- RMQ VM ---
module "rmq_vm" {
  source = "./modules/compute_vm"

  create_vm       = var.enable_rmq_vm
  name            = "rmq-vm"
  machine_type    = var.enable_soc2_compliance ? "n2d-standard-2" : var.vm_types["rmq"]
  zone            = var.zone
  region          = var.region
  subnetwork_id   = module.vpc.subnetwork_id
  boot_disk_image = var.ubuntu_image
  boot_disk_size  = var.vm_boot_disk_sizes["rmq"]
  ip_type         = "INTERNAL_STATIC"
  tags            = ["ssh-allow"]
  labels = merge(local.common_labels, {
    role = "rmq"
  })
  kms_key_name                = var.enable_soc2_compliance ? google_kms_crypto_key.soc2_key[0].id : ""
  enable_confidential_compute = var.enable_soc2_compliance
  enable_oslogin              = var.enable_soc2_compliance
}

# --- Redis VM ---
module "redis_vm" {
  source = "./modules/compute_vm"

  create_vm       = var.enable_redis_vm
  name            = "redis-vm"
  machine_type    = var.enable_soc2_compliance ? "n2d-standard-2" : var.vm_types["redis"]
  zone            = var.zone
  region          = var.region
  subnetwork_id   = module.vpc.subnetwork_id
  boot_disk_image = var.ubuntu_image
  boot_disk_size  = var.vm_boot_disk_sizes["redis"]
  ip_type         = "INTERNAL_EPHEMERAL"
  tags            = ["ssh-allow"]
  labels = merge(local.common_labels, {
    role = "redis"
  })
  kms_key_name                = var.enable_soc2_compliance ? google_kms_crypto_key.soc2_key[0].id : ""
  enable_confidential_compute = var.enable_soc2_compliance
  enable_oslogin              = var.enable_soc2_compliance
}

# --- Monitoring VM ---
module "monitoring_vm" {
  source = "./modules/compute_vm"

  create_vm       = var.enable_monitoring_vm && !var.enable_soc2_compliance
  name            = "monitoring-vm"
  machine_type    = var.enable_soc2_compliance ? "n2d-standard-2" : var.vm_types["monitoring"]
  zone            = var.zone
  region          = var.region
  subnetwork_id   = module.vpc.subnetwork_id
  boot_disk_image = var.ubuntu_image
  boot_disk_size  = var.vm_boot_disk_sizes["monitoring"]
  ip_type         = "EXTERNAL_STATIC"
  tags            = ["ssh-allow"]
  labels = merge(local.common_labels, {
    role = "monitoring"
  })
  kms_key_name                = var.enable_soc2_compliance ? google_kms_crypto_key.soc2_key[0].id : ""
  enable_confidential_compute = var.enable_soc2_compliance
  enable_oslogin              = var.enable_soc2_compliance
}

# --- GitLab VM (Marketplace: GitLab CE on Ubuntu 22.04) ---
module "gitlab_vm" {
  source = "./modules/compute_vm"

  create_vm       = var.enable_gitlab_vm && !var.enable_soc2_compliance
  name            = "gitlab-vm"
  machine_type    = var.enable_soc2_compliance ? "n2d-standard-2" : var.vm_types["gitlab"]
  zone            = var.zone
  region          = var.region
  subnetwork_id   = module.vpc.subnetwork_id
  boot_disk_image = "cloud-infrastructure-services/gitlab-ce-ubuntu-2204"
  boot_disk_size  = var.vm_boot_disk_sizes["gitlab"]
  boot_disk_type  = "pd-ssd"
  ip_type         = "EXTERNAL_STATIC"
  tags            = ["ssh-allow", "http-server", "https-server"]
  labels = merge(local.common_labels, {
    role = "gitlab"
  })

  metadata = {
    google-logging-enabled    = "true"
    google-monitoring-enabled = "true"
  }
  kms_key_name                = var.enable_soc2_compliance ? google_kms_crypto_key.soc2_key[0].id : ""
  enable_confidential_compute = var.enable_soc2_compliance
  enable_oslogin              = var.enable_soc2_compliance
}

# --- GitLab Runner VM ---
module "gitlab_runner_vm" {
  source = "./modules/compute_vm"

  create_vm       = var.enable_gitlab_runner_vm
  name            = "gitlab-runner-vm"
  machine_type    = var.enable_soc2_compliance ? "n2d-standard-2" : var.vm_types["gitlab_runner"]
  zone            = var.zone
  region          = var.region
  subnetwork_id   = module.vpc.subnetwork_id
  boot_disk_image = var.ubuntu_image
  boot_disk_size  = var.vm_boot_disk_sizes["gitlab_runner"]
  ip_type         = "INTERNAL_STATIC"
  tags            = ["ssh-allow"]
  labels = merge(local.common_labels, {
    role = "gitlab-runner"
  })
  kms_key_name                = var.enable_soc2_compliance ? google_kms_crypto_key.soc2_key[0].id : ""
  enable_confidential_compute = var.enable_soc2_compliance
  enable_oslogin              = var.enable_soc2_compliance
}

