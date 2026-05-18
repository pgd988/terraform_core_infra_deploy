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
