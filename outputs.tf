output "app_vm_ip" {
  value = var.enable_app_vm ? google_compute_instance.app_vm[0].network_interface[0].access_config[0].nat_ip : null
}

output "db_vm_ip" {
  value = var.enable_db_vm ? google_compute_instance.db_vm[0].network_interface[0].access_config[0].nat_ip : null
}

output "lb_ip" {
  value = var.enable_lb && var.enable_gke ? google_compute_global_address.gke_ingress_ip[0].address : null
}

output "gke_cluster_name" {
  value = var.enable_gke ? google_container_cluster.primary[0].name : null
}

output "gke_cluster_endpoint" {
  value = var.enable_gke ? google_container_cluster.primary[0].endpoint : null
}
