terraform {
  required_version = ">= 1.3.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.11"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = try("https://${module.gke_cluster.endpoint}", "http://localhost")
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = try(base64decode(module.gke_cluster.cluster_ca_certificate), "")
}

provider "helm" {
  kubernetes {
    host                   = try("https://${module.gke_cluster.endpoint}", "http://localhost")
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = try(base64decode(module.gke_cluster.cluster_ca_certificate), "")
  }
}

resource "google_project_service" "iap" {
  project            = var.project_id
  service            = "iap.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "artifactregistry" {
  project            = var.project_id
  service            = "artifactregistry.googleapis.com"
  disable_on_destroy = false
}

resource "google_artifact_registry_repository" "gke_repo" {
  location      = var.region
  repository_id = "gke-docker-repo"
  description   = "Docker repository for workloads"
  format        = "DOCKER"
  labels        = local.common_labels
  kms_key_name  = var.enable_soc2_compliance ? google_kms_crypto_key.soc2_key[0].id : null

  depends_on = [
    google_project_service.artifactregistry,
    google_kms_crypto_key_iam_member.artifact_registry_kms
  ]
}
