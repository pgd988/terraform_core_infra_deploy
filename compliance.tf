module "soc2_compliance" {
  source = "github.com/GoogleCloudPlatform/gcp-hardening-toolkit//blueprints/gcp-compliance-soc2?ref=main"

  parent          = "projects/${var.project_id}"
  project_id      = var.project_id
  billing_project = var.project_id

  # Toggle all inner modules based on our variable, avoiding the module count error
  enable_soc2_org_policies                             = var.enable_soc2_compliance
  enable_sql_mysql_constraints                         = var.enable_soc2_compliance
  enable_sql_postgresql_constraints                    = var.enable_soc2_compliance
  enable_sql_sqlserver_constraints                     = var.enable_soc2_compliance
  enable_alloydb_constraints                           = var.enable_soc2_compliance
  enable_dns_constraint                                = var.enable_soc2_compliance
  enable_dns_policy_logging_constraint                 = var.enable_soc2_compliance
  enable_bq_dataset_cmek_constraint                    = var.enable_soc2_compliance
  enable_dataproc_cmek_constraint                      = var.enable_soc2_compliance
  enable_instance_no_default_sa_constraint             = var.enable_soc2_compliance
  enable_instance_no_default_sa_full_scopes_constraint = var.enable_soc2_compliance
  enable_instance_no_ip_forwarding_constraint          = var.enable_soc2_compliance
  enable_dnssec_no_rsasha1_constraint                  = var.enable_soc2_compliance
}
