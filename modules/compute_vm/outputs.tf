output "instance_id" {
  description = "The ID of the instance"
  value       = var.create_vm ? google_compute_instance.vm[0].id : null
}

output "internal_ip" {
  description = "The internal IP of the instance"
  value       = var.create_vm ? google_compute_instance.vm[0].network_interface[0].network_ip : null
}

output "external_ip" {
  description = "The external IP of the instance (if EXTERNAL_STATIC)"
  value       = var.create_vm && var.ip_type == "EXTERNAL_STATIC" ? google_compute_instance.vm[0].network_interface[0].access_config[0].nat_ip : null
}
