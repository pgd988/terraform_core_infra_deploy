# ==========================================
# SSL Certificate Generation (Self-Signed)
# ==========================================

resource "tls_private_key" "lb_key" {
  count     = var.create_lb ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_self_signed_cert" "lb_cert" {
  count           = var.create_lb ? 1 : 0
  private_key_pem = tls_private_key.lb_key[0].private_key_pem

  subject {
    common_name         = "example.com"
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
  count       = var.create_lb ? 1 : 0
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
  count       = var.create_lb ? 1 : 0
  name        = "classic-https-lb-ip"
  description = "Static Global IP for the Classic HTTPS Load Balancer"
}

# Standard TCP Health Check for Backend Service over the NEG
resource "google_compute_health_check" "tcp_health_check" {
  count              = var.create_lb ? 1 : 0
  name               = "gke-app-tcp-health-check"
  check_interval_sec = 5
  timeout_sec        = 5

  tcp_health_check {
    port = var.lb_health_check_port
  }
}

# Target HTTPS Proxy combining URL Map and the SSL Cert
resource "google_compute_target_https_proxy" "https_proxy" {
  count            = var.create_lb ? 1 : 0
  name             = "app-https-proxy"
  url_map          = google_compute_url_map.url_map[0].id
  ssl_certificates = [google_compute_ssl_certificate.default[0].id]
}

# Forwarding rule pointing port 443 strictly towards the HTTPS proxy mapped with the static External IP
resource "google_compute_global_forwarding_rule" "https_forwarding_rule" {
  count                 = var.create_lb ? 1 : 0
  name                  = "app-https-forwarding-rule"
  target                = google_compute_target_https_proxy.https_proxy[0].id
  port_range            = "443"
  ip_address            = google_compute_global_address.lb_ip[0].id
  load_balancing_scheme = "EXTERNAL"
}

# ==========================================
# Load Balancer Path & Routing Configuration
# ==========================================

# Retrieve the NEG created by the ingress-nginx-default Helm chart
data "google_compute_network_endpoint_group" "ingress_nginx_neg" {
  count = var.create_lb && var.enable_helm ? 1 : 0
  name  = "ingress-nginx-neg"
  zone  = var.zone
}

# Backend Service for the default NGINX Ingress controller
resource "google_compute_backend_service" "ingress_nginx_backend" {
  count                 = var.create_lb && var.enable_helm ? 1 : 0
  name                  = "ingress-nginx-backend-service"
  protocol              = "HTTP"
  port_name             = "http"
  load_balancing_scheme = "EXTERNAL"
  health_checks         = [google_compute_health_check.tcp_health_check[0].id]

  backend {
    group                 = data.google_compute_network_endpoint_group.ingress_nginx_neg[0].id
    balancing_mode        = "RATE"
    max_rate_per_endpoint = 100
  }
}

# --- ArgoCD Backend ---

# Retrieve the NEG created by the argocd-server service
data "google_compute_network_endpoint_group" "argocd_neg" {
  count = var.create_lb && var.enable_argocd ? 1 : 0
  name  = "argocd-server-neg"
  zone  = var.zone
}

# Backend Service for ArgoCD
resource "google_compute_backend_service" "argocd_backend" {
  count                 = var.create_lb && var.enable_argocd ? 1 : 0
  name                  = "argocd-backend-service"
  protocol              = "HTTP"
  port_name             = "http"
  load_balancing_scheme = "EXTERNAL"
  health_checks         = [google_compute_health_check.tcp_health_check[0].id]

  backend {
    group                 = data.google_compute_network_endpoint_group.argocd_neg[0].id
    balancing_mode        = "RATE"
    max_rate_per_endpoint = 100
  }
}

# --- RabbitMQ Admin Backend ---

# HTTP Health Check for RabbitMQ Admin UI
resource "google_compute_health_check" "rabbitmq_health_check" {
  count              = var.create_lb && var.enable_rmq_vm ? 1 : 0
  name               = "rabbitmq-admin-health-check"
  check_interval_sec = 5
  timeout_sec        = 5

  http_health_check {
    port = var.rmq_admin_port
  }
}

# Backend Service for RabbitMQ Admin UI
resource "google_compute_backend_service" "rabbitmq_backend" {
  count                 = var.create_lb && var.enable_rmq_vm ? 1 : 0
  name                  = "rabbitmq-backend-service"
  protocol              = "HTTP"
  port_name             = "http"
  load_balancing_scheme = "EXTERNAL"
  health_checks         = [google_compute_health_check.rabbitmq_health_check[0].id]

  backend {
    group          = var.rmq_instance_group
    balancing_mode = "UTILIZATION"
  }
}

# URL Map — routes all unmatched requests to the ingress-nginx backend and specific hosts to others
resource "google_compute_url_map" "url_map" {
  count           = var.create_lb && var.enable_helm ? 1 : 0
  name            = "app-url-map"
  default_service = google_compute_backend_service.ingress_nginx_backend[0].id

  dynamic "host_rule" {
    for_each = var.enable_argocd ? [1] : []
    content {
      hosts        = ["acd.example.com"]
      path_matcher = "argocd"
    }
  }

  dynamic "path_matcher" {
    for_each = var.enable_argocd ? [1] : []
    content {
      name            = "argocd"
      default_service = google_compute_backend_service.argocd_backend[0].id
    }
  }

  dynamic "host_rule" {
    for_each = var.enable_rmq_vm ? [1] : []
    content {
      hosts        = [var.rmq_admin_domain]
      path_matcher = "rabbitmq"
    }
  }

  dynamic "path_matcher" {
    for_each = var.enable_rmq_vm ? [1] : []
    content {
      name            = "rabbitmq"
      default_service = google_compute_backend_service.rabbitmq_backend[0].id
    }
  }
}
