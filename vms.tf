# Static External IP for App VM
resource "google_compute_address" "app_static_ip" {
  count  = var.enable_app_vm ? 1 : 0
  name   = "app-vm-static-ip"
  region = var.region
}

# --- App VM ---
resource "google_compute_instance" "app_vm" {
  count               = var.enable_app_vm ? 1 : 0
  name                = "app-vm"
  machine_type        = var.vm_types["app"]
  zone                = var.zone
  deletion_protection = true

  tags = ["ssh-allow", "app"]

  boot_disk {
    initialize_params {
      image = var.ubuntu_image
      size  = var.vm_boot_disk_sizes["app"]
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.subnet.id
    access_config {
      nat_ip = google_compute_address.app_static_ip[0].address
    }
  }
}

# --- DB VM ---
resource "google_compute_instance" "db_vm" {
  count               = var.enable_db_vm ? 1 : 0
  name                = "db-vm"
  machine_type        = var.vm_types["db"]
  zone                = var.zone
  deletion_protection = true

  tags = ["ssh-allow", "db"]

  boot_disk {
    initialize_params {
      image = var.ubuntu_image
      size  = var.vm_boot_disk_sizes["db"]
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.subnet.id
    access_config {
      # Ephemeral IP
    }
  }
}

# --- RMQ VM ---
resource "google_compute_instance" "rmq_vm" {
  count               = var.enable_rmq_vm ? 1 : 0
  name                = "rmq-vm"
  machine_type        = var.vm_types["rmq"]
  zone                = var.zone
  deletion_protection = true

  tags = ["ssh-allow"]

  boot_disk {
    initialize_params {
      image = var.ubuntu_image
      size  = var.vm_boot_disk_sizes["rmq"]
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.subnet.id
    access_config {} # Ephemeral IP
  }
}

# --- Redis VM ---
resource "google_compute_instance" "redis_vm" {
  count               = var.enable_redis_vm ? 1 : 0
  name                = "redis-vm"
  machine_type        = var.vm_types["redis"]
  zone                = var.zone
  deletion_protection = true

  tags = ["ssh-allow"]

  boot_disk {
    initialize_params {
      image = var.ubuntu_image
      size  = var.vm_boot_disk_sizes["redis"]
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.subnet.id
    access_config {} # Ephemeral IP
  }
}

# --- Monitoring VM ---
resource "google_compute_instance" "monitoring_vm" {
  count               = var.enable_monitoring_vm ? 1 : 0
  name                = "monitoring-vm"
  machine_type        = var.vm_types["monitoring"]
  zone                = var.zone
  deletion_protection = true

  tags = ["ssh-allow"]

  boot_disk {
    initialize_params {
      image = var.ubuntu_image
      size  = var.vm_boot_disk_sizes["monitoring"]
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.subnet.id
    access_config {} # Ephemeral IP
  }
}

# --- GitLab VM (Marketplace: GitLab CE on Ubuntu 22.04) ---
resource "google_compute_address" "gitlab_static_ip" {
  count  = var.enable_gitlab_vm ? 1 : 0
  name   = "gitlab-vm-static-ip"
  region = var.region
}

resource "google_compute_instance" "gitlab_vm" {
  count               = var.enable_gitlab_vm ? 1 : 0
  name                = "gitlab-vm"
  machine_type        = var.vm_types["gitlab"]
  zone                = var.zone
  deletion_protection = true

  tags = ["ssh-allow", "http-server", "https-server"]

  metadata = {
    google-logging-enabled    = "true"
    google-monitoring-enabled = "true"
  }

  boot_disk {
    initialize_params {
      image = "cloud-infrastructure-services/gitlab-ce-ubuntu-2204"
      size  = var.vm_boot_disk_sizes["gitlab"]
      type  = "pd-ssd"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.subnet.id
    access_config {
      nat_ip = google_compute_address.gitlab_static_ip[0].address
    }
  }
}

# --- GitLab Runner VM ---
resource "google_compute_instance" "gitlab_runner_vm" {
  count               = var.enable_gitlab_runner_vm ? 1 : 0
  name                = "gitlab-runner-vm"
  machine_type        = var.vm_types["gitlab_runner"]
  zone                = var.zone
  deletion_protection = true

  tags = ["ssh-allow"]

  boot_disk {
    initialize_params {
      image = var.ubuntu_image
      size  = var.vm_boot_disk_sizes["gitlab_runner"]
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.subnet.id
    access_config {} # Ephemeral IP
  }
}
