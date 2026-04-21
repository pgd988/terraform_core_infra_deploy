project_id = "your-gcp-project-id"

# Base Region
region = "us-central1"
zone   = "us-central1-a"

# Features enablement
enable_gke              = false
enable_gke_internals    = false
enable_helm             = false
enable_lb               = false
enable_app_vm           = false
enable_db_vm            = false
enable_rmq_vm           = false
enable_redis_vm         = false
enable_monitoring_vm    = false
enable_gitlab_vm        = false
enable_gitlab_runner_vm = false

# --- Environments & Sizing ---

vm_types = {
  app           = "e2-standard-2"
  db            = "e2-standard-4"
  rmq           = "e2-standard-2"
  redis         = "e2-standard-2"
  monitoring    = "e2-standard-2"
  gitlab        = "e2-standard-8"
  gitlab_runner = "e2-standard-4"
}

# GKE parameters
gke_default_pool_env_label    = "default"
gke_apps_pool_env_label       = "app"

gke_default_pool_machine_type = "e2-standard-2"
gke_default_pool_min_count    = 1
gke_default_pool_max_count    = 2

gke_apps_pool_machine_type = "e2-standard-4"
gke_apps_pool_min_count    = 0
gke_apps_pool_max_count    = 2
