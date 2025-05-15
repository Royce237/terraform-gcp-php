/**
 * Variables for the Cloud SQL module
 */

variable "project_id" {
  description = "The Google Cloud Project ID"
  type        = string
}

variable "region" {
  description = "The GCP region for the Cloud SQL instance"
  type        = string
}

variable "instance_name" {
  description = "The name of the Cloud SQL instance"
  type        = string
}

variable "database_name" {
  description = "The name of the MySQL database"
  type        = string
}

variable "database_version" {
  description = "The version of MySQL to use (e.g., MYSQL_8_0)"
  type        = string
  default     = "MYSQL_8_0"
}

variable "database_tier" {
  description = "The machine type for the Cloud SQL instance"
  type        = string
  default     = "db-f1-micro"
}

variable "database_user" {
  description = "The username for the database"
  type        = string
}

variable "database_password" {
  description = "The password for the database user"
  type        = string
  sensitive   = true
}

variable "enable_backups" {
  description = "Whether to enable backups for the Cloud SQL instance"
  type        = bool
  default     = true
}

variable "enable_point_in_time_recovery" {
  description = "Whether to enable point-in-time recovery for the Cloud SQL instance"
  type        = bool
  default     = false
}

variable "high_availability" {
  description = "Whether to enable high availability for the Cloud SQL instance"
  type        = bool
  default     = false
}

variable "private_network_id" {
  description = "The ID of the VPC network to connect to the Cloud SQL instance"
  type        = string
  default     = ""
}

variable "deletion_protection" {
  description = "Whether to enable deletion protection for the Cloud SQL instance"
  type        = bool
  default     = true
}