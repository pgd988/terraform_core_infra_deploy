# Service Account for GitLab to access GCR
resource "google_service_account" "gcr_access_gitlab" {
  account_id   = "gcr-access-gitlab"
  display_name = "Service Account for GitLab GCR Access"
}

resource "google_project_iam_member" "gcr_access_gitlab_artifactregistry_create_on_push" {
  project = var.project_id
  role    = "roles/artifactregistry.createOnPushRepoAdmin"
  member  = "serviceAccount:${google_service_account.gcr_access_gitlab.email}"
}

resource "google_project_iam_member" "gcr_access_gitlab_artifactregistry_repo_admin" {
  project = var.project_id
  role    = "roles/artifactregistry.repoAdmin"
  member  = "serviceAccount:${google_service_account.gcr_access_gitlab.email}"
}

resource "google_project_iam_member" "gcr_access_gitlab_storage_object_admin" {
  project = var.project_id
  role    = "roles/storage.objectAdmin"
  member  = "serviceAccount:${google_service_account.gcr_access_gitlab.email}"
}

resource "google_project_iam_member" "gcr_access_gitlab_storage_transfer_viewer" {
  project = var.project_id
  role    = "roles/storagetransfer.viewer"
  member  = "serviceAccount:${google_service_account.gcr_access_gitlab.email}"
}
