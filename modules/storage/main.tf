/**
 * Cloud Storage Module
 * Creates a bucket for storing static files
 * 
 * Reference: https://cloud.google.com/storage/docs/terraform-create-bucket
 */

# Create a Cloud Storage bucket for static files
resource "google_storage_bucket" "static_files" {
  name          = var.bucket_name
  project       = var.project_id
  location      = var.bucket_location
  force_destroy = var.force_destroy
  
  # Set uniform bucket-level access
  uniform_bucket_level_access = true
  
  # Set lifecycle rules
  lifecycle_rule {
    condition {
      age = var.lifecycle_age
    }
    action {
      type = var.lifecycle_action
    }
  }
  
  # Enable versioning for production environments
  versioning {
    enabled = var.enable_versioning
  }
  
  # Configure CORS for web access
  cors {
    origin          = var.cors_origins
    method          = ["GET", "HEAD", "OPTIONS"]
    response_header = ["Content-Type", "Access-Control-Allow-Origin"]
    max_age_seconds = 3600
  }
}

# Set public access if enabled
resource "google_storage_bucket_iam_binding" "public_access" {
  count  = var.public_access ? 1 : 0
  bucket = google_storage_bucket.static_files.name
  role   = "roles/storage.objectViewer"
  
  members = [
    "allUsers",
  ]
}

# Create a service account for accessing the bucket
resource "google_service_account" "storage_account" {
  count        = var.create_service_account ? 1 : 0
  account_id   = "${var.bucket_name}-sa"
  display_name = "Service Account for ${var.bucket_name} bucket"
  project      = var.project_id
}

# Grant the service account access to the bucket
resource "google_storage_bucket_iam_binding" "service_account_access" {
  count  = var.create_service_account ? 1 : 0
  bucket = google_storage_bucket.static_files.name
  role   = "roles/storage.objectAdmin"
  
  members = [
    "serviceAccount:${google_service_account.storage_account[0].email}",
  ]
}