# --- App VM ---
module "app_vm" {
  source = "./modules/compute_vm"

  create_vm       = var.enable_app_vm
  name            = "app-vm"
  machine_type    = var.vm_types["app"]
  zone            = var.zone
  region          = var.region
  subnetwork_id   = google_compute_subnetwork.subnet.id
  boot_disk_image = var.ubuntu_image
  boot_disk_size  = var.vm_boot_disk_sizes["app"]
  ip_type         = "EXTERNAL_STATIC"
  tags            = ["ssh-allow", "app"]
}

# --- DB VM ---
module "db_vm" {
  source = "./modules/compute_vm"

  create_vm       = var.enable_db_vm
  name            = "db-vm"
  machine_type    = var.vm_types["db"]
  zone            = var.zone
  region          = var.region
  subnetwork_id   = google_compute_subnetwork.subnet.id
  boot_disk_image = var.ubuntu_image
  boot_disk_size  = var.vm_boot_disk_sizes["db"]
  ip_type         = "INTERNAL_STATIC"
  tags            = ["ssh-allow", "db"]
}

# --- RMQ VM ---
module "rmq_vm" {
  source = "./modules/compute_vm"

  create_vm       = var.enable_rmq_vm
  name            = "rmq-vm"
  machine_type    = var.vm_types["rmq"]
  zone            = var.zone
  region          = var.region
  subnetwork_id   = google_compute_subnetwork.subnet.id
  boot_disk_image = var.ubuntu_image
  boot_disk_size  = var.vm_boot_disk_sizes["rmq"]
  ip_type         = "INTERNAL_STATIC"
  tags            = ["ssh-allow"]
}

# --- Redis VM ---
module "redis_vm" {
  source = "./modules/compute_vm"

  create_vm       = var.enable_redis_vm
  name            = "redis-vm"
  machine_type    = var.vm_types["redis"]
  zone            = var.zone
  region          = var.region
  subnetwork_id   = google_compute_subnetwork.subnet.id
  boot_disk_image = var.ubuntu_image
  boot_disk_size  = var.vm_boot_disk_sizes["redis"]
  ip_type         = "INTERNAL_EPHEMERAL"
  tags            = ["ssh-allow"]
}

# --- Monitoring VM ---
module "monitoring_vm" {
  source = "./modules/compute_vm"

  create_vm       = var.enable_monitoring_vm
  name            = "monitoring-vm"
  machine_type    = var.vm_types["monitoring"]
  zone            = var.zone
  region          = var.region
  subnetwork_id   = google_compute_subnetwork.subnet.id
  boot_disk_image = var.ubuntu_image
  boot_disk_size  = var.vm_boot_disk_sizes["monitoring"]
  ip_type         = "EXTERNAL_STATIC"
  tags            = ["ssh-allow"]
}

# --- GitLab VM (Marketplace: GitLab CE on Ubuntu 22.04) ---
module "gitlab_vm" {
  source = "./modules/compute_vm"

  create_vm       = var.enable_gitlab_vm
  name            = "gitlab-vm"
  machine_type    = var.vm_types["gitlab"]
  zone            = var.zone
  region          = var.region
  subnetwork_id   = google_compute_subnetwork.subnet.id
  boot_disk_image = "cloud-infrastructure-services/gitlab-ce-ubuntu-2204"
  boot_disk_size  = var.vm_boot_disk_sizes["gitlab"]
  boot_disk_type  = "pd-ssd"
  ip_type         = "EXTERNAL_STATIC"
  tags            = ["ssh-allow", "http-server", "https-server"]

  metadata = {
    google-logging-enabled    = "true"
    google-monitoring-enabled = "true"
  }
}

# --- GitLab Runner VM ---
module "gitlab_runner_vm" {
  source = "./modules/compute_vm"

  create_vm       = var.enable_gitlab_runner_vm
  name            = "gitlab-runner-vm"
  machine_type    = var.vm_types["gitlab_runner"]
  zone            = var.zone
  region          = var.region
  subnetwork_id   = google_compute_subnetwork.subnet.id
  boot_disk_image = var.ubuntu_image
  boot_disk_size  = var.vm_boot_disk_sizes["gitlab_runner"]
  ip_type         = "INTERNAL_STATIC"
  tags            = ["ssh-allow"]
}

