# ==============================================================================
# Cloud Logging Configuration
# ==============================================================================
# This configuration adopts the project's default log bucket (_Default),
# configures its retention settings, and creates custom log exclusions
# to prevent low-value/high-volume logs from being processed and stored,
# minimizing ingestion costs.
# ==============================================================================

# Explicitly enable the Cloud Logging API
resource "google_project_service" "logging" {
  project            = var.project_id
  service            = "logging.googleapis.com"
  disable_on_destroy = false
}

# Adopt and configure the _Default logging bucket.
# Cloud Logging automatically creates a "_Default" bucket in every project.
# This resource configures the retention period and location for it.
resource "google_logging_project_bucket_config" "default_bucket" {
  project        = var.project_id
  location       = var.log_bucket_location
  bucket_id      = "_Default"
  retention_days = var.log_bucket_retention_days
  description    = "Default logging bucket managed by Terraform for log storage and lifecycle control."

  depends_on = [
    google_project_service.logging
  ]
}

locals {
  # Default log exclusions to cut noise and monitoring/ingestion costs out-of-the-box.
  # You can easily edit or add custom exclusions directly in this block, or pass
  # them dynamically via the `log_exclusions` input variable.
  default_exclusions = {
    "exclude-gke-verbose-logs" = {
      description = "Exclude GKE system containers verbose logs (DEBUG and INFO severity) to cut noise and cost"
      filter      = "resource.type=\"k8s_container\" AND severity<=INFO"
      disabled    = false
    }
    "exclude-loadbalancer-healthchecks" = {
      description = "Exclude load balancer health checks with 200 OK statuses to prevent high ingestion volume"
      filter      = "resource.type=\"http_load_balancer\" AND httpRequest.status=200"
      disabled    = false
    }
    "exclude-compute-verbose" = {
      description = "Exclude verbose VM logs that are below WARNING severity"
      filter      = "resource.type=\"gce_instance\" AND severity<WARNING"
      disabled    = false
    }
  }

  # Merge the default exclusions with any custom user-supplied exclusions from the variable
  all_exclusions = merge(local.default_exclusions, var.log_exclusions)
}

# Define project-level log exclusions to cut out unnecessary high-volume logs
# before they are ingested into Cloud Logging, reducing monitoring costs.
resource "google_logging_project_exclusion" "exclusions" {
  for_each    = local.all_exclusions
  name        = each.key
  project     = var.project_id
  description = each.value.description
  filter      = each.value.filter
  disabled    = lookup(each.value, "disabled", false)

  depends_on = [
    google_project_service.logging
  ]
}
