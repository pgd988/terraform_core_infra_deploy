variable "create_cluster" {
  description = "Whether to create the GKE cluster and associated resources"
  type        = bool
  default     = true
}

variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region"
  type        = string
}

variable "zone" {
  description = "The specific GCP zone to deploy resources in"
  type        = string
}

variable "cluster_name" {
  description = "The name of the GKE cluster"
  type        = string
}

variable "network_id" {
  description = "The VPC network ID"
  type        = string
}

variable "subnetwork_id" {
  description = "The subnetwork ID"
  type        = string
}

variable "cluster_secondary_range_name" {
  description = "The name of the secondary range to use for pods"
  type        = string
}

variable "services_secondary_range_name" {
  description = "The name of the secondary range to use for services"
  type        = string
}

variable "main_domain" {
  description = "The primary domain for the organization (used for Google Groups RBAC)"
  type        = string
}

variable "enable_workload_identity" {
  description = "Enable Workload Identity on the GKE cluster"
  type        = bool
  default     = false
}

# Default Node Pool
variable "default_pool_min_count" {
  type    = number
  default = 1
}

variable "default_pool_max_count" {
  type    = number
  default = 3
}

variable "default_pool_machine_type" {
  type    = string
  default = "e2-micro"
}

variable "default_pool_disk_size" {
  type    = number
  default = 50
}

variable "default_pool_env_label" {
  type    = string
  default = "default"
}

# Apps Node Pool
variable "apps_pool_min_count" {
  type    = number
  default = 1
}

variable "apps_pool_max_count" {
  type    = number
  default = 5
}

variable "apps_pool_machine_type" {
  type    = string
  default = "e2-micro"
}

variable "apps_pool_disk_size" {
  type    = number
  default = 50
}

variable "apps_pool_env_label" {
  type    = string
  default = "app"
}

variable "resource_labels" {
  description = "GCP resource labels to apply to the cluster and node pools"
  type        = map(string)
  default     = {}
}
