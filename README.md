# GCP Core Infrastructure Deployment

This repository contains a modular and highly configurable Terraform project to deploy core infrastructure on Google Cloud Platform (GCP). It is designed to provision a mix of Virtual Machines, a Google Kubernetes Engine (GKE) cluster, Load Balancing, and required networking/security components.

## Features

This project is feature-flag driven, allowing you to selectively deploy only the components you need via `terraform.tfvars`.

### Compute (VMs)
You can provision standalone VMs for various roles using the `enable_*_vm` variables. Each VM has customizable machine types and boot disk sizes:
- **App VM** (`enable_app_vm`) - Application workloads.
- **Database VM** (`enable_db_vm`) - Database hosting.
- **RabbitMQ VM** (`enable_rmq_vm`) - Message broker.
- **Redis VM** (`enable_redis_vm`) - In-memory cache.
- **Monitoring VM** (`enable_monitoring_vm`) - Observability stack.
- **GitLab VM** (`enable_gitlab_vm`) - Code hosting and CI/CD. Deployed from the [GCP Marketplace GitLab CE image](https://console.cloud.google.com/marketplace/product/cloud-infrastructure-services/gitlab-ce-ubuntu-22-04) (Ubuntu 22.04, SSD boot disk). Recommended machine type: `e2-standard-4` (4 vCPU, 16 GB RAM).
- **GitLab Runner VM** (`enable_gitlab_runner_vm`) - CI/CD job execution.

### Kubernetes (GKE)
- **GKE Cluster** (`enable_gke`): Provisions a regional GKE cluster with configurable default and application node pools (machine types, disk sizes, autoscaling limits).
- **Internal Resources** (`enable_gke_internals`): Deploys internal Kubernetes resources such as namespaces (`app_namespace`).
- **Helm Deployments** (`enable_helm`): Conditionally deploys Helm charts to the cluster. Currently configured to deploy an `ingress-nginx-default` chart.

### Load Balancing & Networking
- **Classic HTTPS Load Balancer** (`enable_lb`): Deploys a global load balancer with a static IP and self-signed SSL certificates.
- **Network Endpoint Groups (NEG)**: All unmatched requests are routed to the NGINX Ingress controller via a dedicated NEG backend.
- **Path-based Routing** (`lb_paths.tf`): Centralized file for managing URL map routing rules and backend assignments.
- **VPC & Subnets**: Custom VPC and subnet configuration.
- **Firewalls**: Configured for SSH access, health checks, and specific internal communication (e.g., allowing `10.0.0.0/8` to access database ports).

### IAM & Security
- **Service Accounts**: Provisions specific service accounts, such as `gcr-access-gitlab`, with least-privilege IAM roles (Artifact Registry Admin, Storage Object Admin, etc.) for CI/CD integrations.

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
   
   enable_gke  = true
   enable_helm = true
   enable_lb   = true
   
   enable_app_vm = false
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

- `variables.tf`: Input variable definitions and default values.
- `terraform.tfvars`: Environment-specific variable overrides.
- `vpc.tf` / `firewall.tf`: Networking components.
- `vms.tf`: Standalone compute instance definitions.
- `gke.tf` / `gke_internals.tf` / `gke_helm.tf`: Kubernetes cluster, namespaces, and workloads.
- `lb.tf`: Global HTTPS Load Balancer core components (SSL, IP, health checks, proxy, forwarding).
- `lb_paths.tf`: Load Balancer routing configuration (URL map, NEG backends).
- `service_accounts.tf`: IAM and Service Account definitions.
- `outputs.tf`: Important output variables (IPs, cluster names, etc.).
- `helm/`: Directory containing local Helm charts (e.g., `default-ingress-nginx`).
