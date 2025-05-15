/**
 * Output values after Terraform deployment
 * Provides important URLs and connection information
 */

output "project_id" {
  description = "The Google Cloud Project ID"
  value       = var.project_id
}

output "cloud_run_url" {
  description = "The URL of the deployed Cloud Run service"
  value       = module.cloudrun.service_url
}

output "load_balancer_ip" {
  description = "The external IP address of the Load Balancer"
  value       = module.loadbalancer.external_ip
}

output "application_url" {
  description = "The URL to access the application"
  value       = var.domain_name != "" ? "https://${var.domain_name}" : module.loadbalancer.external_ip_url
}

output "storage_bucket" {
  description = "The name of the Cloud Storage bucket for static files"
  value       = module.storage.bucket_name
}

output "cloudsql_connection_name" {
  description = "The connection name for the Cloud SQL instance"
  value       = module.cloudsql.connection_name
}

output "cloudsql_instance_name" {
  description = "The name of the Cloud SQL instance"
  value       = module.cloudsql.instance_name
}

output "database_name" {
  description = "The name of the MySQL database"
  value       = var.db_name
}

output "database_user" {
  description = "The username for the database"
  value       = var.db_user
}

output "connection_instructions" {
  description = "Instructions for connecting to the database from Cloud Run"
  value       = "Your Cloud Run service is configured to connect to the Cloud SQL instance via the Cloud SQL Auth Proxy."
}