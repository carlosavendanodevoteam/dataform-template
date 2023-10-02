resource "google_bigquery_dataset" "usecase_bigquery_datasets" {
  for_each   = toset(local.bigquery_datasets)
  project    = var.project_id
  dataset_id = "d_${local.dataform_config["vars"]["use_case"]}_${each.key}_${local.env}"
  location   = local.location
}
