output "app_vm_ip" {
  value = module.app_vm.external_ip
}

output "db_vm_ip" {
  value = module.db_vm.internal_ip
}

output "lb_ip" {
  value = module.load_balancer.lb_ip
}

output "gke_cluster_name" {
  value = module.gke_cluster.name
}

output "gke_cluster_endpoint" {
  value = module.gke_cluster.endpoint
}

output "artifact_registry_id" {
  description = "The ID of the artifact registry repository"
  value       = google_artifact_registry_repository.gke_repo.id
}

output "default_log_bucket_id" {
  description = "The ID of the default log bucket configuration"
  value       = google_logging_project_bucket_config.default_bucket.id
}

output "active_log_exclusions" {
  description = "Map of active log exclusion filters"
  value       = { for k, v in google_logging_project_exclusion.exclusions : k => v.filter }
}
