# Allow LB health checks
resource "google_compute_firewall" "allow_lb_health_check" {
  name    = "allow-lb-health-check"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["80", "443", "8080"]
  }

  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
}

# DB Ingress firewall rule (allow internal network to talk to DB)
resource "google_compute_firewall" "db_ingress" {
  name    = "allow-db-ingress"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["5432", "3306", "27017"] # Common DB ports
  }

  source_ranges = ["10.0.0.0/8"]
  target_tags   = ["db"]
}

# Allow SSH ingress
resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-ssh-ingress"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["ssh-allow"]
}
