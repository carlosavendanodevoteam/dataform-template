resource "google_project_iam_member" "bigquery_viewers" {
  for_each = toset(local.datasets_viewers)
  project  = var.project_id
  role     = "roles/bigquery.dataViewer"
  member   = each.key
}
