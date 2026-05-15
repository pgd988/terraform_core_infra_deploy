output "app_vm_ip" {
  value = module.app_vm.external_ip
}

output "db_vm_ip" {
  value = module.db_vm.internal_ip
}

output "lb_ip" {
  value = var.enable_lb && var.enable_gke ? google_compute_global_address.lb_ip[0].address : null
}

output "gke_cluster_name" {
  value = var.enable_gke ? google_container_cluster.primary[0].name : null
}

output "gke_cluster_endpoint" {
  value = var.enable_gke ? google_container_cluster.primary[0].endpoint : null
}
