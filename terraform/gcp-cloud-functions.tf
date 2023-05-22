########################################
## stream_to_bigquery
########################################

/*
stream_to_bigquery
*/

variable "pyfunc_info_stream_to_bigquery" {
  type = map(string)
  default = {
    name    = "stream_to_bigquery"
    version = "v3"
  }
}

# zip up our source code
data "archive_file" "pyfunc_zip_stream_to_bigquery" {
  type        = "zip"
  source_dir  = "${path.root}/python-functions/${var.pyfunc_info_stream_to_bigquery.name}/"
  output_path = "${path.root}/python-functions/zipped/${var.pyfunc_info_stream_to_bigquery.name}_${var.pyfunc_info_stream_to_bigquery.version}.zip"
}

# create the storage bucket
resource "google_storage_bucket" "pyfunc_stream_to_bigquery" {
  name = "pyfunc_${var.pyfunc_info_stream_to_bigquery.name}"
  location = var.gcp_location
}

# place the zip-ed code in the bucket
resource "google_storage_bucket_object" "pyfunc_zip_stream_to_bigquery" {
  name   = "${var.pyfunc_info_stream_to_bigquery.name}_${var.pyfunc_info_stream_to_bigquery.version}.zip"
  bucket = google_storage_bucket.pyfunc_stream_to_bigquery.name
  source = "${path.root}/python-functions/zipped/${var.pyfunc_info_stream_to_bigquery.name}_${var.pyfunc_info_stream_to_bigquery.version}.zip"
}

# define the function resource
resource "google_cloudfunctions_function" "pyfunc_stream_to_bigquery" {
  name                  = var.pyfunc_info_stream_to_bigquery.name
  description           = "stream_to_bigquery"
  source_archive_bucket = google_storage_bucket.pyfunc_stream_to_bigquery.name
  source_archive_object = google_storage_bucket_object.pyfunc_zip_stream_to_bigquery.name
  trigger_http          = true
  entry_point           = "stream_to_bigquery"
  timeout               = 540
  runtime               = "python37"
}

# IAM entry for all users to invoke the function
resource "google_cloudfunctions_function_iam_member" "pyfunc_iam_invoker_stream_to_bigquery" {
  project        = google_cloudfunctions_function.pyfunc_stream_to_bigquery.project
  region         = google_cloudfunctions_function.pyfunc_stream_to_bigquery.region
  cloud_function = google_cloudfunctions_function.pyfunc_stream_to_bigquery.name
  role           = "roles/cloudfunctions.invoker"
  member         = "allUsers"
}