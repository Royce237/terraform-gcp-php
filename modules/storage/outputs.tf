/**
 * Outputs from the Cloud Storage module
 */

output "bucket_name" {
  description = "The name of the Cloud Storage bucket"
  value       = google_storage_bucket.static_files.name
}

output "bucket_url" {
  description = "The URL of the Cloud Storage bucket"
  value       = "gs://${google_storage_bucket.static_files.name}"
}

output "bucket_self_link" {
  description = "The URI of the Cloud Storage bucket"
  value       = google_storage_bucket.static_files.self_link
}

output "service_account_email" {
  description = "The email of the service account for the bucket"
  value       = var.create_service_account ? google_service_account.storage_account[0].email : ""
}