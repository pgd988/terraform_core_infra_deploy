resource "google_compute_address" "static_ip_external" {
  count  = var.create_vm && var.ip_type == "EXTERNAL_STATIC" ? 1 : 0
  name   = "${var.name}-static-ip"
  region = var.region
}

resource "google_compute_address" "static_ip_internal" {
  count        = var.create_vm && var.ip_type == "INTERNAL_STATIC" ? 1 : 0
  name         = "${var.name}-static-ip"
  region       = var.region
  subnetwork   = var.subnetwork_id
  address_type = "INTERNAL"
}

resource "google_compute_instance" "vm" {
  count               = var.create_vm ? 1 : 0
  name                = var.name
  machine_type        = var.machine_type
  zone                = var.zone
  deletion_protection = true

  tags     = var.tags
  metadata = var.metadata

  boot_disk {
    initialize_params {
      image = var.boot_disk_image
      size  = var.boot_disk_size
      type  = var.boot_disk_type
    }
  }

  network_interface {
    subnetwork = var.subnetwork_id

    # Use network_ip for INTERNAL_STATIC
    network_ip = var.ip_type == "INTERNAL_STATIC" ? google_compute_address.static_ip_internal[0].address : null

    # Use access_config with nat_ip for EXTERNAL_STATIC
    dynamic "access_config" {
      for_each = var.ip_type == "EXTERNAL_STATIC" ? [1] : []
      content {
        nat_ip = google_compute_address.static_ip_external[0].address
      }
    }
  }
}
