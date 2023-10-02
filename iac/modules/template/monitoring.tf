resource "google_monitoring_notification_channel" "email_dev_contact" {
  display_name = "Email DEV contact"
  type         = "email"
  labels = {
    email_address = "dummy@email.com"
  }
}

resource "google_monitoring_alert_policy" "dataform_failed_executions_alert_policy" {
  display_name = "Log | Dataform | Failed execution"
  enabled      = var.env == "dv" || var.env == "np" ? false : true
  combiner     = "OR"
  conditions {
    display_name = "At least one failed Dataform execution."
    condition_matched_log {
      filter = "resource.type=\"dataform.googleapis.com/Repository\" jsonPayload.@type=\"type.googleapis.com/google.cloud.dataform.logging.v1.WorkflowInvocationCompletionLogEntry\" jsonPayload.terminalState=\"FAILED\""
      label_extractors = {
        "workflow_invocation_id" = "EXTRACT(jsonPayload.workflowInvocationId)"
        "location"               = "EXTRACT(resource.labels.location)"
        "repository_id"          = "EXTRACT(resource.labels.repository_id)"
      }
    }
  }

  notification_channels = [google_monitoring_notification_channel.email_dev_contact.name]
  alert_strategy {
    notification_rate_limit {
      period = "600s"
    }
  }
}
