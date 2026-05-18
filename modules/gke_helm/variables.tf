variable "enable_helm" {
  description = "Enable deployment of Helm charts"
  type        = bool
  default     = true
}

variable "enable_argocd" {
  description = "Enable ArgoCD resources"
  type        = bool
  default     = false
}

variable "app_namespace" {
  description = "Application namespace"
  type        = string
}

variable "argocd_namespace" {
  description = "ArgoCD namespace"
  type        = string
}

variable "argo_rollouts_namespace" {
  description = "Argo Rollouts namespace"
  type        = string
}

variable "argocd_git_repo_url" {
  description = "Git repository URL for ArgoCD"
  type        = string
}

variable "argocd_ssh_key_ready" {
  description = "Is the ArgoCD SSH key ready?"
  type        = bool
}

variable "main_domain" {
  description = "Main domain for RBAC groups"
  type        = string
}
