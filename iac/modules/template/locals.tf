locals {
  general_config  = yamldecode(file("${var.config_path}/config.yaml"))
  dataform_config = jsondecode(file("${var.config_path}/dataform.json"))

  project_id               = var.project_id
  env                      = var.env
  region                   = local.general_config["region"]
  location                 = local.dataform_config["defaultLocation"]
  dataform_git_url         = local.general_config["github_repository_url"]
  dataform_repository_name = local.general_config["github_repository_name"]
  dataform_scheduler_cron  = local.general_config["dataform_scheduler_cron"]
  use_case                 = replace(local.dataform_config["vars"]["use_case"], "_", "-")

  bigquery_datasets = local.general_config["bigquery"]["datasets_short_names"]
  datasets_viewers  = local.general_config["bigquery"]["datasets_viewers"]
}
