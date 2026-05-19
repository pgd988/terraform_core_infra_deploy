variable "vpc_name" {
  description = "The name of the VPC network"
  type        = string
}

variable "region" {
  description = "The GCP region for the subnetwork"
  type        = string
}

variable "enable_flow_logs" {
  description = "Enable VPC Flow Logs on the subnetwork"
  type        = bool
  default     = false
}

variable "enable_cloud_nat" {
  description = "Enable Cloud NAT gateway"
  type        = bool
  default     = false
}
