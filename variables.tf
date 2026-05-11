variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region"
  type        = string
  default     = "us-central1"
}

variable "main_domain" {
  description = "The primary domain for the organization (used for Google Groups RBAC, etc.)"
  type        = string
}

# --- Feature Flags ---

variable "enable_gke" {
  description = "Enable GKE cluster creation"
  type        = bool
  default     = false
}

variable "enable_workload_identity" {
  description = "Enable Workload Identity on the GKE cluster"
  type        = bool
  default     = false
}

variable "enable_gke_internals" {
  description = "Deploy internal GKE resources (like namespaces). Requires enable_gke = true."
  type        = bool
  default     = false
}

variable "enable_helm" {
  description = "Deploy Helm charts to GKE. Requires enable_gke = true."
  type        = bool
  default     = false
}

variable "enable_lb" {
  description = "Enable Load Balancer creation (requires enable_gke = true)"
  type        = bool
  default     = false
}

variable "enable_argocd" {
  description = "Enable ArgoCD deployment"
  type        = bool
  default     = false
}

variable "argocd_ssh_key_ready" {
  description = "Set to true once the SSH key has been manually added to Secret Manager"
  type        = bool
  default     = false
}

variable "argocd_git_repo_url" {
  description = "The Git repository URL for ArgoCD access (e.g., git@github.com:your-org/your-repo.git)"
  type        = string
  default     = "git@github.com:your-org/your-repo.git"
}

# --- LB Params ---

variable "lb_health_check_port" {
  description = "The TCP port used for the LB health check"
  type        = number
  default     = 80
}

variable "lb_cert_trigger" {
  description = "Change this value (e.g. increase integer) to force a regeneration of the self-signed SSL certificate"
  type        = string
  default     = "1"
}

variable "enable_app_vm" {
  type    = bool
  default = false
}

variable "enable_db_vm" {
  type    = bool
  default = false
}

variable "enable_rmq_vm" {
  type    = bool
  default = false
}

variable "enable_redis_vm" {
  type    = bool
  default = false
}

variable "enable_monitoring_vm" {
  type    = bool
  default = false
}

variable "enable_gitlab_vm" {
  type    = bool
  default = false
}

variable "enable_gitlab_runner_vm" {
  type    = bool
  default = false
}

# --- Environment Specifics ---

variable "vpc_name" {
  type    = string
  default = "main-vpc"
}

variable "zone" {
  description = "The specific GCP zone to deploy resources in"
  type        = string
  default     = "us-central1-a"
}

# VM Types
variable "vm_types" {
  description = "Map of VM names to machine types"
  type        = map(string)
  default = {
    app           = "e2-micro"
    db            = "e2-micro"
    rmq           = "e2-micro"
    redis         = "e2-micro"
    monitoring    = "e2-micro"
    gitlab        = "e2-micro"
    gitlab_runner = "e2-micro"
  }
}

variable "vm_boot_disk_sizes" {
  description = "Map of VM names to boot disk sizes in GB"
  type        = map(number)
  default = {
    app           = 20
    db            = 50
    rmq           = 20
    redis         = 20
    monitoring    = 30
    gitlab        = 50
    gitlab_runner = 30
  }
}

variable "ubuntu_image" {
  type    = string
  default = "ubuntu-os-cloud/ubuntu-2204-lts"
}

# GKE Params
variable "gke_cluster_name" {
  description = "The name of the primary GKE cluster"
  type        = string
  default     = "primary-cluster"
}

variable "gke_default_pool_env_label" {
  type    = string
  default = "default"
}

variable "gke_apps_pool_env_label" {
  type    = string
  default = "app"
}

variable "gke_default_pool_machine_type" {
  type    = string
  default = "e2-micro"
}

variable "gke_default_pool_disk_size" {
  type    = number
  default = 50
}

variable "gke_apps_pool_machine_type" {
  type    = string
  default = "e2-micro"
}

variable "gke_apps_pool_disk_size" {
  type    = number
  default = 50
}

variable "app_namespace" {
  description = "The name of the Kubernetes namespace for the application"
  type        = string
  default     = "app-namespace"
}

variable "gke_default_pool_min_count" {
  type    = number
  default = 1
}

variable "gke_default_pool_max_count" {
  type    = number
  default = 3
}

variable "gke_apps_pool_min_count" {
  type    = number
  default = 1
}

variable "gke_apps_pool_max_count" {
  type    = number
  default = 5
}
