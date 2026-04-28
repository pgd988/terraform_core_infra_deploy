# ==========================================
# Load Balancer Path & Routing Configuration
# ==========================================

# Retrieve the NEG created by the ingress-nginx-default Helm chart
data "google_compute_network_endpoint_group" "ingress_nginx_neg" {
  count      = var.enable_lb && var.enable_gke && var.enable_gke_internals && var.enable_helm ? 1 : 0
  name       = "ingress-nginx-neg"
  zone       = var.zone
  depends_on = [helm_release.ingress_nginx_default]
}

# Backend Service for the default NGINX Ingress controller
resource "google_compute_backend_service" "ingress_nginx_backend" {
  count                 = var.enable_lb && var.enable_gke && var.enable_gke_internals && var.enable_helm ? 1 : 0
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
  count      = var.enable_lb && var.enable_gke && var.enable_gke_internals && var.enable_argocd ? 1 : 0
  name       = "argocd-server-neg"
  zone       = var.zone
  depends_on = [kubernetes_service.argocd_server_svc]
}

# Backend Service for ArgoCD
resource "google_compute_backend_service" "argocd_backend" {
  count                 = var.enable_lb && var.enable_gke && var.enable_gke_internals && var.enable_argocd ? 1 : 0
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

# URL Map — routes all unmatched requests to the ingress-nginx backend and specific hosts to others
resource "google_compute_url_map" "url_map" {
  count           = var.enable_lb && var.enable_gke && var.enable_gke_internals && var.enable_helm ? 1 : 0
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
}
