output "lb_ip" {
  description = "The static IP address of the load balancer"
  value       = var.create_lb ? google_compute_global_address.lb_ip[0].address : null
}
