resource "google_project_service" "artifactregistry" {
  count              = var.enable_gke ? 1 : 0
  project            = var.project_id
  service            = "artifactregistry.googleapis.com"
  disable_on_destroy = false
}

resource "google_artifact_registry_repository" "gke_repo" {
  count         = var.enable_gke ? 1 : 0
  location      = var.region
  repository_id = "gke-docker-repo"
  description   = "Docker repository for GKE workloads"
  format        = "DOCKER"

  depends_on = [google_project_service.artifactregistry]
}

resource "google_container_cluster" "primary" {
  count    = var.enable_gke ? 1 : 0
  name     = var.gke_cluster_name
  location = var.zone

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1

  network    = google_compute_network.vpc.id
  subnetwork = google_compute_subnetwork.subnet.id

  ip_allocation_policy {
    cluster_secondary_range_name  = google_compute_subnetwork.subnet.secondary_ip_range[0].range_name
    services_secondary_range_name = google_compute_subnetwork.subnet.secondary_ip_range[1].range_name
  }

  node_config {
    tags = ["gke-node"]
  }

  # Enable Google Groups for RBAC — groups must be nested under gke-security-groups@domain
  authenticator_groups_config {
    security_group = "gke-security-groups@${var.main_domain}"
  }
}

resource "google_container_node_pool" "default_pool" {
  count    = var.enable_gke ? 1 : 0
  name     = "default-pool"
  location = var.zone
  cluster  = google_container_cluster.primary[0].name

  autoscaling {
    min_node_count = var.gke_default_pool_min_count
    max_node_count = var.gke_default_pool_max_count
  }

  node_config {
    preemptible  = false
    machine_type = var.gke_default_pool_machine_type
    disk_size_gb = var.gke_default_pool_disk_size

    labels = {
      env = var.gke_default_pool_env_label
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/trace.append",
    ]
    tags = ["gke-node"]
  }
}

resource "google_container_node_pool" "apps_pool" {
  count    = var.enable_gke ? 1 : 0
  name     = "apps-pool"
  location = var.zone
  cluster  = google_container_cluster.primary[0].name

  autoscaling {
    min_node_count = var.gke_apps_pool_min_count
    max_node_count = var.gke_apps_pool_max_count
  }

  node_config {
    spot         = true
    machine_type = var.gke_apps_pool_machine_type
    disk_size_gb = var.gke_apps_pool_disk_size

    labels = {
      env = var.gke_apps_pool_env_label
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/trace.append",
    ]
    tags = ["gke-node", "app"]
  }
}
