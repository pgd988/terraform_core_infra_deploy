variable "enable_internals" {
  description = "Enable internal Kubernetes resources"
  type        = bool
  default     = true
}

variable "enable_argocd" {
  description = "Enable ArgoCD resources"
  type        = bool
  default     = false
}

variable "app_namespace" {
  description = "Namespace for the application"
  type        = string
  default     = "app"
}

variable "argocd_ssh_key_ready" {
  description = "Is the ArgoCD SSH key ready in Secret Manager?"
  type        = bool
  default     = false
}

variable "argocd_git_repo_url" {
  description = "Git repository URL for ArgoCD"
  type        = string
  default     = ""
}

variable "labels" {
  description = "GCP resource labels to apply to created GCP resources"
  type        = map(string)
  default     = {}
}
