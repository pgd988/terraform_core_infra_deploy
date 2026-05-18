locals {
  common_labels = {
    managed-by  = "terraform"
    environment = terraform.workspace == "default" ? "dev" : terraform.workspace
    project     = var.project_id
  }
}
