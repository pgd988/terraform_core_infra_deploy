resource "helm_release" "ingress_nginx_default" {
  count = var.enable_helm ? 1 : 0

  name  = "ingress-nginx-default"
  chart = "./helm/default-ingress-nginx"

  namespace = var.app_namespace
}

resource "helm_release" "argocd" {
  count = var.enable_helm && var.enable_argocd ? 1 : 0

  name      = "argocd"
  chart     = "./helm/argocd"
  namespace = var.argocd_namespace

  set {
    name  = "bootstrapRepoUrl"
    value = var.argocd_git_repo_url
  }

  set {
    name  = "argocdSshKeyReady"
    value = var.argocd_ssh_key_ready
  }
}

resource "helm_release" "argo_rollouts" {
  count = var.enable_helm && var.enable_argocd ? 1 : 0

  name       = "argo-rollouts"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-rollouts"
  namespace  = var.argo_rollouts_namespace
}

resource "helm_release" "cluster_infra_mgmt" {
  count = var.enable_helm ? 1 : 0

  name  = "cluster-infra-mgmt"
  chart = "./helm/cluster-infra-mgmt"

  namespace = var.app_namespace

  set {
    name  = "appNamespace"
    value = var.app_namespace
  }

  set {
    name  = "developersGroup"
    value = "developers@${var.main_domain}"
  }

  set {
    name  = "devopsGroup"
    value = "devops@${var.main_domain}"
  }
}
