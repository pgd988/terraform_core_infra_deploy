output "name" {
  description = "The name of the GKE cluster"
  value       = var.create_cluster ? google_container_cluster.primary[0].name : null
}

output "endpoint" {
  description = "The endpoint for the GKE cluster"
  value       = var.create_cluster ? google_container_cluster.primary[0].endpoint : null
}

output "cluster_ca_certificate" {
  description = "The cluster CA certificate"
  value       = var.create_cluster ? google_container_cluster.primary[0].master_auth[0].cluster_ca_certificate : null
}

