output "app_namespace" {
  description = "The application namespace"
  value       = var.enable_internals ? kubernetes_namespace.app_ns[0].metadata[0].name : null
}

output "argocd_namespace" {
  description = "The ArgoCD namespace"
  value       = var.enable_internals && var.enable_argocd ? kubernetes_namespace.argocd_ns[0].metadata[0].name : null
}

output "argo_rollouts_namespace" {
  description = "The Argo Rollouts namespace"
  value       = var.enable_internals && var.enable_argocd ? kubernetes_namespace.argo_rollouts_ns[0].metadata[0].name : null
}

output "argocd_secret_ready" {
  description = "Indicates whether the ArgoCD git repo creds secret has been created"
  value       = var.enable_internals && var.enable_argocd && var.argocd_ssh_key_ready
}
