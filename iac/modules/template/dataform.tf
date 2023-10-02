module "dataform" {
  source                         = "git@github.com:devoteamgcloud/terraform-google-dataform.git?ref=v2.0.1"
  project_id                     = local.project_id
  env                            = local.env
  region                         = local.region
  dataform_git_url               = local.dataform_git_url
  dataform_default_branch        = local.env == "pd" ? "main" : "integration"
  dataform_repository_name       = local.dataform_repository_name
  scheduler_cron                 = local.env == "dv" ? "" : local.dataform_scheduler_cron
  usecase                        = local.use_case
  is_deploy_sa_project_iam_admin = true
}
