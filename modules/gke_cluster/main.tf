resource "google_container_cluster" "primary" {
  count    = var.create_cluster ? 1 : 0
  name     = var.cluster_name
  location = var.zone

  remove_default_node_pool = true
  initial_node_count       = 1

  network    = var.network_id
  subnetwork = var.subnetwork_id

  ip_allocation_policy {
    cluster_secondary_range_name  = var.cluster_secondary_range_name
    services_secondary_range_name = var.services_secondary_range_name
  }

  resource_labels = var.resource_labels

  dynamic "database_encryption" {
    for_each = var.kms_key_name != "" ? [1] : []
    content {
      state    = "ENCRYPTED"
      key_name = var.kms_key_name
    }
  }

  dynamic "confidential_nodes" {
    for_each = var.enable_confidential_nodes ? [1] : []
    content {
      enabled = true
    }
  }

  node_config {
    tags = ["gke-node"]
  }

  authenticator_groups_config {
    security_group = "gke-security-groups@${var.main_domain}"
  }

  dynamic "workload_identity_config" {
    for_each = var.enable_workload_identity ? [1] : []
    content {
      workload_pool = "${var.project_id}.svc.id.goog"
    }
  }

  datapath_provider = "ADVANCED_DATAPATH"

  monitoring_config {
    advanced_datapath_observability_config {
      enable_metrics = true
      enable_relay   = true
    }
  }
}

resource "google_container_node_pool" "default_pool" {
  count    = var.create_cluster ? 1 : 0
  name     = "default-pool"
  location = var.zone
  cluster  = google_container_cluster.primary[0].name

  autoscaling {
    min_node_count = var.default_pool_min_count
    max_node_count = var.default_pool_max_count
  }

  node_config {
    preemptible       = false
    machine_type      = var.default_pool_machine_type
    disk_size_gb      = var.default_pool_disk_size
    boot_disk_kms_key = var.kms_key_name != "" ? var.kms_key_name : null

    labels = {
      env = var.default_pool_env_label
    }

    resource_labels = var.resource_labels

    oauth_scopes = [
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/trace.append",
    ]
    tags = ["gke-node"]

    dynamic "workload_metadata_config" {
      for_each = var.enable_workload_identity ? [1] : []
      content {
        mode = "GKE_METADATA"
      }
    }
  }
}

resource "google_container_node_pool" "apps_pool" {
  count    = var.create_cluster ? 1 : 0
  name     = "apps-pool"
  location = var.zone
  cluster  = google_container_cluster.primary[0].name

  autoscaling {
    min_node_count = var.apps_pool_min_count
    max_node_count = var.apps_pool_max_count
  }

  node_config {
    spot              = true
    machine_type      = var.apps_pool_machine_type
    disk_size_gb      = var.apps_pool_disk_size
    boot_disk_kms_key = var.kms_key_name != "" ? var.kms_key_name : null

    labels = {
      env = var.apps_pool_env_label
    }

    resource_labels = var.resource_labels

    oauth_scopes = [
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/trace.append",
    ]
    tags = ["gke-node", "app"]

    dynamic "workload_metadata_config" {
      for_each = var.enable_workload_identity ? [1] : []
      content {
        mode = "GKE_METADATA"
      }
    }
  }
}
