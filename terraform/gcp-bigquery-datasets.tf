########################################
## telemetry_events
########################################

resource "google_bigquery_dataset" "telemetry_events" {
  dataset_id = "telemetry_events"
  location   = var.gcp_location
}
