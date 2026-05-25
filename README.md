# GCP Core Infrastructure Deployment

This repository contains a modular and highly configurable Terraform project to deploy core infrastructure on Google Cloud Platform (GCP). It is designed to provision a mix of Virtual Machines, a Google Kubernetes Engine (GKE) cluster, Load Balancing, and required networking/security components.

## Features

This project is feature-flag driven, allowing you to selectively deploy only the components you need via `terraform.tfvars`.

### Compute (VMs)
You can provision standalone VMs for various roles using the `enable_*_vm` variables. Each VM has customizable machine types and boot disk sizes:
- **App VM** (`enable_app_vm`) - Application workloads (Static External IP).
- **Database VM** (`enable_db_vm`) - Database hosting (Static Internal IP).
- **RabbitMQ VM** (`enable_rmq_vm`) - Message broker (Static Internal IP). Its admin UI is automatically placed into an Unmanaged Instance Group (`rabbitmq-production`) and exposed via the Global HTTPS Load Balancer.
- **Redis VM** (`enable_redis_vm`) - In-memory cache (Ephemeral Internal IP).
- **Monitoring VM** (`enable_monitoring_vm`) - Observability stack (Static External IP).
- **GitLab VM** (`enable_gitlab_vm`) - Code hosting and CI/CD (Static External IP). Deployed from the [GCP Marketplace GitLab CE image](https://console.cloud.google.com/marketplace/product/cloud-infrastructure-services/gitlab-ce-ubuntu-22-04) (Ubuntu 22.04, SSD boot disk). Recommended machine type: `e2-standard-4` (4 vCPU, 16 GB RAM).
- **GitLab Runner VM** (`enable_gitlab_runner_vm`) - CI/CD job execution (Static Internal IP).

### Kubernetes (GKE)
- **GKE Cluster** (`enable_gke`): Provisions a regional GKE cluster with configurable default and application node pools (machine types, disk sizes, autoscaling limits). Also provisions a Google Artifact Registry (`gke-docker-repo`) for Docker workloads.
- **Workload Identity** (`enable_workload_identity`): Toggles Workload Identity on the GKE cluster and node pools, allowing Kubernetes service accounts to securely authenticate to Google Cloud APIs.
- **Internal Resources** (`enable_gke_internals`): Deploys internal Kubernetes resources such as namespaces (`app_namespace`).
- **Helm Deployments** (`enable_helm`): Conditionally deploys Helm charts to the cluster. Currently configured to deploy an `ingress-nginx-default` chart (with a dynamic config-reloader sidecar).
- **ArgoCD & Argo Rollouts** (`enable_argocd`): Deploys ArgoCD (from local chart) and Argo Rollouts (from remote chart) into their respective namespaces. Configures a standalone NEG for the ArgoCD server.
- **ArgoCD Git Credentials & Bootstrap** (`argocd_ssh_key_ready` & `argocd_git_repo_url`): Employs a secure two-step process using GCP Secret Manager to inject SSH repository credentials into ArgoCD. Once the keys are ready, it dynamically templates and deploys a Helm post-install hook to initialize the root "App of Apps" bootstrap Application.
- **Cluster Infra Management** (`cluster-infra-mgmt` Helm chart): Deploys cluster-internal resources including network policies, RBAC roles, and bindings.
- **Google Groups RBAC**: The cluster is configured with `authenticator_groups_config` to support IAM-connected RBAC via Google Groups. Groups must be nested under the `gke-security-groups@<main_domain>` parent group. Currently configured groups:
  - `developers@<main_domain>` — read-only access to the app namespace (no secrets)
  - `devops@<main_domain>` — cluster-wide access to all namespaces (no secrets)

### Load Balancing & Networking
- **Classic HTTPS Load Balancer** (`enable_lb`): Deploys a global load balancer with a static IP and self-signed SSL certificates.
- **Network Endpoint Groups (NEG)**: All unmatched requests are routed to the NGINX Ingress controller via a dedicated NEG backend.
- **Path/Host-based Routing**: Centralized manage-by-URL map routing rules and backend assignments. Includes dynamic host-based routing for ArgoCD (`acd.example.com`) and the RabbitMQ Admin UI (configurable via `rmq_admin_domain`).
- **VPC, Subnets & Cloud NAT**: Custom VPC and subnet configuration. Optional Cloud NAT (`enable_cloud_nat`) allows internal-only VMs to securely access the internet using a static external IP. Cloud NAT is automatically enabled when SOC2 compliance is active.
- **Firewalls**: Configured for health checks, specific internal communication (e.g., allowing `10.0.0.0/8` to access database ports), and secure SSH access strictly via GCP Identity-Aware Proxy (IAP) (`35.235.240.0/20`).

### IAM & Security
- **Service Accounts**: Provisions specific service accounts, such as `gcr-access-gitlab`, with least-privilege IAM roles (Artifact Registry Admin, Storage Object Admin, etc.) for CI/CD integrations.
- **GCP Secret Manager Integration**: Securely manages the ArgoCD SSH Git credentials (`argocd-git-ssh-key`), preventing private keys from being exposed in plaintext Terraform state.
- **IAP SSH Access**: SSH access is restricted to the GCP IAP service. Ensure your users have the `roles/iap.tunnelResourceAccessor` and OS login permissions to connect to the VMs via the Google Cloud Console.

### Standardized Resource Labeling
- **Global Locals (`locals.tf`)**: Implements a consistent tagging strategy across all supported GCP resources. Base labels (like `managed-by`, `environment`, and `project`) flow from a central `locals.tf` file down into all modules (VMs, GKE clusters, Secret Manager, Artifact Registry).
- **Dynamic Role Tags**: VM modules merge the baseline labels with specific role-based tags (e.g., `role = "db"`) to facilitate exact billing allocation and metadata tracking.

### Dynamic SOC2 Compliance
- **GCP Hardening Toolkit Integration**: The `enable_soc2_compliance` variable seamlessly integrates the official Google Cloud [SOC2 Compliance Blueprint](https://github.com/GoogleCloudPlatform/gcp-hardening-toolkit/tree/main/blueprints/gcp-compliance-soc2).
- **Automated Infrastructure Adaptation**: Toggling this flag automatically reconfigures the underlying infrastructure to strictly adhere to SOC2 Organization Policies:
  - **Confidential Computing**: Overrides VM and GKE node pool machine types to `n2d-standard-2` and enables `confidential_instance_config`/`confidential_nodes`.
  - **Customer-Managed Encryption Keys (CMEK)**: Dynamically provisions KMS Keyrings and CryptoKeys, grants IAM decryption roles, and encrypts VM boot disks, GKE application-layer secrets, and Artifact Registry.
  - **VPC Flow Logs & OS Login**: Automatically enables subnetwork flow logs (50% sample rate) and OS Login across all compute instances.
  - **External IP Restriction**: Safely skips the deployment of VMs requiring external IPs (App, Monitoring, GitLab) to comply with the `compute.vmExternalIpAccess` block policy.

### Cloud Logging & Cost Control
- **Default Log Bucket Configuration** (`log_bucket_location` & `log_bucket_retention_days`): Adopts and configures the default GCP logging bucket (`_Default`), allowing precise control over data storage duration (retention days) and physical storage location.
- **Log Exclusions** (`log_exclusions`): Out-of-the-box support for custom log exclusions to filter out high-volume, low-value logs before ingestion, minimizing GCP Cloud Logging costs. Pre-configured exclusions include:
  - **GKE Verbose Logs**: Filters out `INFO` and `DEBUG` level container logs.
  - **Load Balancer Health Checks**: Excludes successful (`200 OK`) HTTP health check entries.
  - **Compute Engine Verbose Logs**: Excludes VM system and agent logs below `WARNING` severity.

#### Adding Custom Log Exclusions
To add new exclusions or customize existing ones, define the `log_exclusions` map in your `terraform.tfvars` file.

> [!NOTE]
> Since the default system exclusions are defined in `logging.tf`, any custom exclusions defined in your `terraform.tfvars` map are automatically **merged** with the defaults. You do not need to repeat the defaults in your own configuration.

```hcl
log_exclusions = {
  "exclude-app-polling-endpoint" = {
    description = "Exclude highly frequent custom app polling/healthz endpoints"
    filter      = "resource.type=\"k8s_container\" AND resource.labels.namespace_name=\"app-namespace\" AND textPayload =~ \"GET /healthz\""
    disabled    = false
  }
}
```

### Google Groups for RBAC — Setup Requirements

The GKE cluster uses Google Groups to map RBAC policies to your organization's identity. For this to work:

1. **Create a parent group** called `gke-security-groups@<your-domain>` in [Google Groups](https://groups.google.com) or Google Admin Console.
2. **Nest your RBAC groups** (`developers@<your-domain>`, `devops@<your-domain>`) as **members** of the parent group.
3. **Set `main_domain`** in `terraform.tfvars` to your organization's domain.

> **Important:** Only groups nested under `gke-security-groups@<domain>` are recognized by GKE. Adding users directly to the parent group does not grant any cluster access.

## Prerequisites

- Terraform v1.0+
- Google Cloud SDK (`gcloud`) authenticated with adequate permissions.
- Helm v3 (if deploying Helm charts)

## Usage

1. **Initialize Terraform:**
   ```bash
   terraform init
   ```

2. **Configure Variables:**
   Update your `terraform.tfvars` file to enable the specific components and sizes you need. 
   ```hcl
   project_id = "your-gcp-project-id"
   region     = "us-central1"
   
   enable_gke               = true
   enable_workload_identity = true
   enable_helm              = true
   enable_lb                = true
   enable_argocd            = true
   
   # Two-step ArgoCD Git setup
   argocd_git_repo_url  = "git@github.com:your-org/your-repo.git"
   argocd_ssh_key_ready = false # Set to true ONLY after manually adding the key to Secret Manager
   enable_app_vm = false
   
   # Cloud Logging & Cost Control Configuration
   log_bucket_location       = "global"
   log_bucket_retention_days = 30
   
   # ... other configurations
   ```

3. **Review the Plan:**
   ```bash
   terraform plan
   ```

4. **Apply the Infrastructure:**
   ```bash
   terraform apply
   ```

## Repository Structure

The project follows a clean, modular architecture:

- **Root Configuration:**
  - `variables.tf` / `terraform.tfvars`: Input variables and environment overrides.
  - `locals.tf`: Centralized local variables, such as global resource labels.
  - `network.tf`: Instantiates the `vpc` and `firewall` modules.
  - `load_balancer.tf`: Instantiates the `load_balancer` module.
  - `vms.tf`: Standalone compute instance definitions (calling `compute_vm` module).
  - `gke.tf` / `gke_internals.tf` / `gke_helm.tf`: Kubernetes root configurations calling their respective modules.
  - `service_accounts.tf` / `providers.tf`: IAM, Providers, and Artifact Registry.
  - `compliance.tf`: Instantiates the Google Cloud SOC2 hardening blueprint.
  - `logging.tf`: Adopts the default GCP logging bucket and sets custom cost-saving exclusions.
  - `kms.tf`: Provisions Customer-Managed Encryption Keys (CMEK) when SOC2 is enabled.
  - `outputs.tf`: Important output variables.
  
- **Modules (`modules/`):**
  - `vpc`: Encapsulates network and subnet creation (including GKE secondary ranges).
  - `firewall`: Manages health check, DB, and SSH/IAP ingress rules.
  - `load_balancer`: Global HTTPS Load Balancer, SSL certificates, routing (URL Maps), and backend NEG definitions.
  - `gke_cluster`: Regional GKE cluster and node pool definitions.
  - `gke_internals`: Cluster internal resources (Namespaces, Services, Secrets).
  - `gke_helm`: Helm chart deployments (Nginx Ingress, ArgoCD, etc.).
  - `compute_vm`: Standardized Compute Engine instance definition.

- **Helm Charts (`helm/`):**
  - Directory containing local Helm charts (e.g., `default-ingress-nginx`, `argocd`, `cluster-infra-mgmt`).
