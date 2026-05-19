# Data source to get the project number for service agent identities
data "google_project" "project" {}

resource "google_project_service" "kms" {
  count              = var.enable_soc2_compliance ? 1 : 0
  project            = var.project_id
  service            = "cloudkms.googleapis.com"
  disable_on_destroy = false
}

resource "google_kms_key_ring" "soc2_keyring" {
  count      = var.enable_soc2_compliance ? 1 : 0
  name       = "soc2-keyring-${random_id.kms_suffix.hex}"
  location   = var.region
  depends_on = [google_project_service.kms]
}

resource "random_id" "kms_suffix" {
  byte_length = 4
}

resource "google_kms_crypto_key" "soc2_key" {
  count    = var.enable_soc2_compliance ? 1 : 0
  name     = "soc2-key"
  key_ring = google_kms_key_ring.soc2_keyring[0].id
  purpose  = "ENCRYPT_DECRYPT"

  lifecycle {
    prevent_destroy = true
  }
}

# Grant Compute Engine Service Agent access to the KMS key
resource "google_kms_crypto_key_iam_member" "compute_engine_kms" {
  count         = var.enable_soc2_compliance ? 1 : 0
  crypto_key_id = google_kms_crypto_key.soc2_key[0].id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:service-${data.google_project.project.number}@compute-system.iam.gserviceaccount.com"
}

# Grant GKE Service Agent access to the KMS key
resource "google_kms_crypto_key_iam_member" "gke_kms" {
  count         = var.enable_soc2_compliance ? 1 : 0
  crypto_key_id = google_kms_crypto_key.soc2_key[0].id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:service-${data.google_project.project.number}@container-engine-robot.iam.gserviceaccount.com"
}

# Grant Artifact Registry Service Agent access to the KMS key
resource "google_kms_crypto_key_iam_member" "artifact_registry_kms" {
  count         = var.enable_soc2_compliance ? 1 : 0
  crypto_key_id = google_kms_crypto_key.soc2_key[0].id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:service-${data.google_project.project.number}@gcp-sa-artifactregistry.iam.gserviceaccount.com"
}
