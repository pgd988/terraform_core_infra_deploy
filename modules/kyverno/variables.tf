variable "enable_kyverno" {
  description = "Whether to deploy the Kyverno policy engine"
  type        = bool
  default     = false
}

variable "kyverno_mode" {
  description = "Validation failure action for Kyverno policies (audit or enforce)"
  type        = string
  default     = "audit"
}
