# ==========================================
# SSL Certificate Generation (Self-Signed)
# ==========================================

resource "tls_private_key" "lb_key" {
  count     = var.enable_lb && var.enable_gke && var.enable_gke_internals ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_self_signed_cert" "lb_cert" {
  count           = var.enable_lb && var.enable_gke && var.enable_gke_internals ? 1 : 0
  private_key_pem = tls_private_key.lb_key[0].private_key_pem

  subject {
    common_name  = "example.com" # Replace or parameterize
    organization = "Demo App"
  }

  validity_period_hours = 8760

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

resource "google_compute_ssl_certificate" "default" {
  count       = var.enable_lb && var.enable_gke && var.enable_gke_internals ? 1 : 0
  name        = "self-signed-lb-cert"
  description = "Self-signed certificate for the Classic HTTPS LB"
  private_key = tls_private_key.lb_key[0].private_key_pem
  certificate = tls_self_signed_cert.lb_cert[0].cert_pem
}

# ==========================================
# Load Balancer Components
# ==========================================

# Explicit Static Global External IP
resource "google_compute_global_address" "lb_ip" {
  count       = var.enable_lb && var.enable_gke && var.enable_gke_internals ? 1 : 0
  name        = "classic-https-lb-ip"
  description = "Static Global IP for the Classic HTTPS Load Balancer"
}

# Standard TCP Health Check for Backend Service over the NEG
resource "google_compute_health_check" "tcp_health_check" {
  count              = var.enable_lb && var.enable_gke && var.enable_gke_internals ? 1 : 0
  name               = "gke-app-tcp-health-check"
  check_interval_sec = 5
  timeout_sec        = 5
  
  tcp_health_check {
    port = 80
  }
}

# Retrieve the dynamically created NEG natively from the backend Kubernetes Service deployment
data "google_compute_network_endpoint_group" "app_neg" {
  count      = var.enable_lb && var.enable_gke && var.enable_gke_internals ? 1 : 0
  name       = "app-backend-neg"
  zone       = var.zone
  depends_on = [kubernetes_service.app_svc]
}

# Global Backend Service pointing to Zonal NEG
resource "google_compute_backend_service" "backend" {
  count                 = var.enable_lb && var.enable_gke && var.enable_gke_internals ? 1 : 0
  name                  = "gke-app-backend-service"
  protocol              = "HTTP"
  port_name             = "http"
  load_balancing_scheme = "EXTERNAL"
  health_checks         = [google_compute_health_check.tcp_health_check[0].id]

  backend {
    group                 = data.google_compute_network_endpoint_group.app_neg[0].id
    balancing_mode        = "RATE"
    max_rate_per_endpoint = 100
  }
}

# URL Map directly tied to backend service
resource "google_compute_url_map" "url_map" {
  count           = var.enable_lb && var.enable_gke && var.enable_gke_internals ? 1 : 0
  name            = "app-url-map"
  default_service = google_compute_backend_service.backend[0].id
}

# Target HTTPS Proxy combining URL Map and the SSL Cert
resource "google_compute_target_https_proxy" "https_proxy" {
  count            = var.enable_lb && var.enable_gke && var.enable_gke_internals ? 1 : 0
  name             = "app-https-proxy"
  url_map          = google_compute_url_map.url_map[0].id
  ssl_certificates = [google_compute_ssl_certificate.default[0].id]
}

# Forwarding rule pointing port 443 strictly towards the HTTPS proxy mapped with the static External IP
resource "google_compute_global_forwarding_rule" "https_forwarding_rule" {
  count                 = var.enable_lb && var.enable_gke && var.enable_gke_internals ? 1 : 0
  name                  = "app-https-forwarding-rule"
  target                = google_compute_target_https_proxy.https_proxy[0].id
  port_range            = "443"
  ip_address            = google_compute_global_address.lb_ip[0].id
  load_balancing_scheme = "EXTERNAL"
}
