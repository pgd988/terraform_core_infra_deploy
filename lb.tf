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
    common_name         = "example.com" # Replace or parameterize
    organization        = "Demo App"
    organizational_unit = var.lb_cert_trigger
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
    port = var.lb_health_check_port
  }
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
