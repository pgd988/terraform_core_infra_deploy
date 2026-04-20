zone = "us-central1-a"

vm_types = {
  app           = "e2-standard-2"
  db            = "e2-standard-4"
  rmq           = "e2-standard-2"
  redis         = "e2-standard-2"
  monitoring    = "e2-standard-2"
  gitlab        = "e2-standard-8"
  gitlab_runner = "e2-standard-4"
}

# GKE parameters for Prod
gke_default_pool_env_label    = "default"
gke_apps_pool_env_label       = "app"

gke_default_pool_machine_type = "e2-standard-2"
gke_default_pool_min_count    = 2
gke_default_pool_max_count    = 5

gke_apps_pool_machine_type = "e2-standard-4"
gke_apps_pool_min_count    = 3
gke_apps_pool_max_count    = 10
