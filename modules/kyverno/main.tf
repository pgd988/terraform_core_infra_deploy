resource "helm_release" "kyverno" {
  count = var.enable_kyverno ? 1 : 0

  name             = "kyverno"
  repository       = "https://kyverno.github.io/kyverno/"
  chart            = "kyverno"
  namespace        = "kyverno"
  create_namespace = true
}

resource "helm_release" "kyverno_policies" {
  count = var.enable_kyverno ? 1 : 0

  name      = "kyverno-policies"
  chart     = "./helm/kyverno-policies"
  namespace = "kyverno"

  set {
    name  = "mode"
    value = var.kyverno_mode
  }

  depends_on = [
    helm_release.kyverno
  ]
}
