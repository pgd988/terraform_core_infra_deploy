variable "create_lb" {
  description = "Whether to create the load balancer resources"
  type        = bool
  default     = true
}

variable "zone" {
  description = "The zone used for looking up Network Endpoint Groups (NEGs)"
  type        = string
}

variable "enable_helm" {
  description = "Whether Helm charts (like ingress-nginx) are enabled"
  type        = bool
  default     = true
}

variable "enable_argocd" {
  description = "Whether ArgoCD is enabled"
  type        = bool
  default     = false
}

variable "lb_cert_trigger" {
  description = "A trigger to rotate the self-signed SSL cert"
  type        = string
}

variable "lb_health_check_port" {
  description = "The port used by the health check for the load balancer"
  type        = string
}
