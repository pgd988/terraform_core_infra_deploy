variable "create_vm" {
  description = "Whether to create the VM and associated resources"
  type        = bool
  default     = true
}

variable "name" {
  description = "Name of the VM"
  type        = string
}

variable "machine_type" {
  description = "Machine type for the VM"
  type        = string
}

variable "zone" {
  description = "Zone to deploy the VM"
  type        = string
}

variable "region" {
  description = "Region to deploy the VM (required if allocating a static IP)"
  type        = string
}

variable "tags" {
  description = "Network tags for the VM"
  type        = list(string)
  default     = ["ssh-allow"]
}

variable "boot_disk_image" {
  description = "Image for the boot disk"
  type        = string
}

variable "boot_disk_size" {
  description = "Size of the boot disk in GB"
  type        = number
}

variable "boot_disk_type" {
  description = "Type of the boot disk"
  type        = string
  default     = "pd-standard"
}

variable "subnetwork_id" {
  description = "The subnetwork to attach the VM to"
  type        = string
}

variable "ip_type" {
  description = "Type of IP to allocate: EXTERNAL_STATIC, INTERNAL_STATIC, or INTERNAL_EPHEMERAL"
  type        = string
  default     = "INTERNAL_EPHEMERAL"

  validation {
    condition     = contains(["EXTERNAL_STATIC", "INTERNAL_STATIC", "INTERNAL_EPHEMERAL"], var.ip_type)
    error_message = "ip_type must be EXTERNAL_STATIC, INTERNAL_STATIC, or INTERNAL_EPHEMERAL."
  }
}

variable "metadata" {
  description = "Metadata key/value pairs to make available from within the instance"
  type        = map(string)
  default     = {}
}
