terraform {
  required_version = ">= 1.2.9, < 2.0.0"
  backend "gcs" {
    bucket = "dgc-sandbox-hrialan-terraform"
    prefix = "dataform-sample-project/"
  }
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.5.0, <5.0.0"
    }
  }
}

provider "google" {
  project = local.project_id
}

locals {
  env        = "dv"
  project_id = "sandbox-hrialan"
}

# Create initial ressources (Cloud build triggers, activates apis, creates a custom sa for cloud build)
#-- Start by commenting the template modules and applying the init module
module "init" {
  source      = "../../modules/init"
  config_path = "./../../../"
  project_id  = local.project_id
  env         = local.env
}

module "template" {
  source      = "../../modules/template"
  config_path = "./../../../"
  env         = local.env
  project_id  = local.project_id
}
