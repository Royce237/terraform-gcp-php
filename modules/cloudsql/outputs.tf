/**
 * Outputs from the Cloud SQL module
 */

output "instance_name" {
  description = "The name of the Cloud SQL instance"
  value       = google_sql_database_instance.mysql_instance.name
}

output "connection_name" {
  description = "The connection name for the Cloud SQL instance"
  value       = google_sql_database_instance.mysql_instance.connection_name
}

output "instance_ip" {
  description = "The IP address of the Cloud SQL instance"
  value       = google_sql_database_instance.mysql_instance.ip_address.0.ip_address
}

output "database_name" {
  description = "The name of the MySQL database"
  value       = google_sql_database.database.name
}

output "instance_self_link" {
  description = "The URI of the Cloud SQL instance"
  value       = google_sql_database_instance.mysql_instance.self_link
}