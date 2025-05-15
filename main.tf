/**
 * Main Terraform configuration file
 * Orchestrates the creation of Google Cloud resources for a PHP application
 */

# Configure the Google Cloud provider
provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

# Optionally create a new Google Cloud project
# Uncomment if you need to create a new project
/*
resource "google_project" "php_app_project" {
  name            = var.project_name
  project_id      = var.project_id
  billing_account = var.billing_account_id
}

resource "google_project_service" "gcp_services" {
  for_each = toset([
    "cloudresourcemanager.googleapis.com",
    "compute.googleapis.com",
    "container.googleapis.com",
    "containerregistry.googleapis.com",
    "cloudbuild.googleapis.com",
    "cloudrun.googleapis.com",
    "sqladmin.googleapis.com",
    "iam.googleapis.com",
    "secretmanager.googleapis.com",
    "storage.googleapis.com"
  ])

  project = google_project.php_app_project.project_id
  service = each.key

  disable_dependent_services = true
}
*/

# Enable required APIs for existing project
resource "google_project_service" "gcp_services" {
  for_each = toset([
    "cloudresourcemanager.googleapis.com",
    "compute.googleapis.com",
    "container.googleapis.com",
    "containerregistry.googleapis.com",
    "cloudbuild.googleapis.com",
    "cloudrun.googleapis.com",
    "sqladmin.googleapis.com",
    "iam.googleapis.com",
    "secretmanager.googleapis.com",
    "storage.googleapis.com"
  ])

  project = var.project_id
  service = each.key

  disable_dependent_services = true
  disable_on_destroy         = false
}

# Create Cloud SQL instance and database
module "cloudsql" {
  source = "./modules/cloudsql"

  project_id          = var.project_id
  region              = var.region
  instance_name       = var.db_instance_name
  database_name       = var.db_name
  database_version    = var.db_version
  database_tier       = var.db_tier
  database_user       = var.db_user
  database_password   = var.db_password
  deletion_protection = var.environment == "production" ? true : false

  depends_on = [google_project_service.gcp_services]
}

# Create Cloud Storage bucket for static files
module "storage" {
  source = "./modules/storage"

  project_id   = var.project_id
  bucket_name  = "${var.project_id}-${var.environment}-static-files"
  bucket_location = var.region
  force_destroy = var.environment == "production" ? false : true

  depends_on = [google_project_service.gcp_services]
}

# Create Cloud Run service with PHP-FPM application
module "cloudrun" {
  source = "./modules/cloudrun"

  project_id         = var.project_id
  region             = var.region
  service_name       = "${var.app_name}-${var.environment}"
  container_image    = var.container_image
  container_port     = 8080
  cpu_limit          = var.app_cpu
  memory_limit       = var.app_memory
  concurrency        = var.app_concurrency
  min_instances      = var.app_min_instances
  max_instances      = var.app_max_instances
  
  # Environment variables for the Cloud Run service
  environment_variables = {
    "DB_HOST"     = module.cloudsql.connection_name
    "DB_NAME"     = var.db_name
    "DB_USER"     = var.db_user
    "DB_PASSWORD" = var.db_password
    "STORAGE_BUCKET" = module.storage.bucket_name
    "APP_ENV"     = var.environment
  }

  depends_on = [
    google_project_service.gcp_services,
    module.cloudsql,
    module.storage
  ]
}

# Create Cloud Load Balancer
module "loadbalancer" {
  source = "./modules/loadbalancer"

  project_id        = var.project_id
  region            = var.region
  name              = "${var.app_name}-${var.environment}-lb"
  cloud_run_service = module.cloudrun.service_name
  ssl_certificate   = var.ssl_certificate_id
  domain_name       = var.domain_name

  depends_on = [
    google_project_service.gcp_services,
    module.cloudrun
  ]
}