resource "kubernetes_namespace" "app_ns" {
  # Only create if both the GKE cluster itself, and the internal deployments feature are enabled.
  count = var.enable_gke && var.enable_gke_internals ? 1 : 0

  metadata {
    name = var.app_namespace

    labels = {
      managed-by = "terraform"
    }
  }
}

resource "kubernetes_service" "app_svc" {
  count = var.enable_gke && var.enable_gke_internals ? 1 : 0

  metadata {
    name      = "app-backend-svc"
    namespace = kubernetes_namespace.app_ns[0].metadata[0].name

    # This annotation provisions the standalone zonal NEG automatically via GKE
    annotations = {
      "cloud.google.com/neg" = jsonencode({
        "exposed_ports" = {
          "80" = { "name" = "app-backend-neg" }
        }
      })
    }
  }

  spec {
    # This selector assumes your helm chart or pod deployment will use the label app=my-app.
    selector = {
      app = "my-app"
    }

    port {
      port        = 80
      target_port = 8080
    }

    type = "ClusterIP"
  }
}

# --- ArgoCD Resources ---
resource "kubernetes_namespace" "argocd_ns" {
  count = var.enable_gke && var.enable_gke_internals && var.enable_argocd ? 1 : 0

  metadata {
    name = "argocd"

    labels = {
      managed-by = "terraform"
    }
  }
}

resource "kubernetes_service" "argocd_server_svc" {
  count = var.enable_gke && var.enable_gke_internals && var.enable_argocd ? 1 : 0

  metadata {
    name      = "argocd-server-neg-svc"
    namespace = kubernetes_namespace.argocd_ns[0].metadata[0].name

    annotations = {
      "cloud.google.com/neg" = jsonencode({
        "exposed_ports" = {
          "8080" = { "name" = "argocd-server-neg" }
        }
      })
    }
  }

  spec {
    selector = {
      "app.kubernetes.io/name" = "argocd-server"
    }

    port {
      port        = 8080
      target_port = 8080
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_namespace" "argo_rollouts_ns" {
  count = var.enable_gke && var.enable_gke_internals && var.enable_argocd ? 1 : 0

  metadata {
    name = "argo-rollouts"

    labels = {
      managed-by = "terraform"
    }
  }
}

# --- ArgoCD Git SSH Key Management ---

resource "google_secret_manager_secret" "argocd_ssh_key" {
  count     = var.enable_argocd ? 1 : 0
  secret_id = "argocd-git-ssh-key"

  replication {
    auto {}
  }
}

data "google_secret_manager_secret_version" "argocd_ssh_key_version" {
  count   = var.enable_argocd && var.argocd_ssh_key_ready ? 1 : 0
  secret  = google_secret_manager_secret.argocd_ssh_key[0].secret_id
  version = "latest"
}

resource "kubernetes_secret" "argocd_repo_creds" {
  count = var.enable_gke && var.enable_gke_internals && var.enable_argocd && var.argocd_ssh_key_ready ? 1 : 0

  metadata {
    name      = "argocd-repo-creds"
    namespace = kubernetes_namespace.argocd_ns[0].metadata[0].name
    labels = {
      "argocd.argoproj.io/secret-type" = "repository"
    }
  }

  data = {
    type          = "git"
    url           = var.argocd_git_repo_url
    sshPrivateKey = data.google_secret_manager_secret_version.argocd_ssh_key_version[0].secret_data
  }
}
