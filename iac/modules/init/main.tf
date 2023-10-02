variable "project_id" { type = string }
variable "env" { type = string }
variable "config_path" { type = string }


terraform {
  required_version = ">= 1.2.9, < 2.0.0"
  required_providers {
    google = ">= 4.5.0, <5.0.0"
  }
}

locals {
  general_config  = yamldecode(file("${var.config_path}/config.yaml"))
  dataform_config = jsondecode(file("${var.config_path}/dataform.json"))

  use_case = replace(local.dataform_config["vars"]["use_case"], "_", "-")
}

resource "google_project_service" "apis" {
  for_each           = toset(local.general_config["apis_to_activate"])
  project            = var.project_id
  service            = each.value
  disable_on_destroy = false
}

resource "google_secret_manager_secret" "cloudbuild-ssh-key" {
  secret_id = "cloudbuild-ssh-key-${var.env}"
  replication {
    automatic = true
  }
  depends_on = [
    google_project_service.apis
  ]
}

# Service account to get access to data from other GCP project
resource "google_service_account" "deploy" {
  project      = var.project_id
  account_id   = "deploy"
  description  = "Service account for deploying infrastructure on the project: ${local.dataform_config["vars"]["use_case"]} (to be used instead of the default Cloud Build account)"
  display_name = "deploy service account"
}

output "deploy" {
  value = google_service_account.deploy.email
}


resource "google_cloudbuild_trigger" "tf-plan" {
  github {
    #TO CHANGE
    ##################################################
    owner = local.general_config["github_organization_name"]
    name  = local.general_config["github_repository_name"]
    ##################################################
    pull_request {
      branch = (var.env == "pd") ? "^(main)$" : "^(integration)$"
    }
  }

  substitutions = {
    _APPLY_CHANGES = "false"
    _ENV           = var.env
    _USECASE       = local.use_case
    _REGION        = local.general_config["region"]
  }
  name            = "${local.use_case}-plan"
  filename        = "cloudbuild.yaml"
  service_account = google_service_account.deploy.id
}

resource "google_cloudbuild_trigger" "tf-apply" {
  github {
    #TO CHANGE
    ##################################################
    owner = local.general_config["github_organization_name"]
    name  = local.general_config["github_repository_name"]
    ##################################################
    push {
      branch = (var.env == "pd") ? "^(main)$" : "^(integration)$"
    }
  }

  substitutions = {
    _APPLY_CHANGES = "true"
    _ENV           = var.env
    _USECASE       = local.use_case
    _REGION        = local.general_config["region"]
  }
  name            = "${local.use_case}-apply"
  filename        = "cloudbuild.yaml"
  service_account = google_service_account.deploy.id
}
