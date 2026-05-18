output "network_id" {
  description = "The ID of the VPC network"
  value       = google_compute_network.vpc.id
}

output "network_name" {
  description = "The name of the VPC network"
  value       = google_compute_network.vpc.name
}

output "subnetwork_id" {
  description = "The ID of the subnetwork"
  value       = google_compute_subnetwork.subnet.id
}

output "pod_secondary_range_name" {
  description = "The name of the secondary range for pods"
  value       = google_compute_subnetwork.subnet.secondary_ip_range[0].range_name
}

output "service_secondary_range_name" {
  description = "The name of the secondary range for services"
  value       = google_compute_subnetwork.subnet.secondary_ip_range[1].range_name
}
