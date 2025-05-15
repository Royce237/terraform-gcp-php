/**
 * Variables for the Cloud Run module
 */

variable "project_id" {
  description = "The Google Cloud Project ID"
  type        = string
}

variable "region" {
  description = "The GCP region for the Cloud Run service"
  type        = string
}

variable "service_name" {
  description = "The name of the Cloud Run service"
  type        = string
}

variable "container_image" {
  description = "The container image to deploy (e.g., gcr.io/my-project/php-app:latest)"
  type        = string
}

variable "container_port" {
  description = "The port the container listens on"
  type        = number
  default     = 8080
}

variable "cpu_limit" {
  description = "The CPU limit for the Cloud Run service (e.g., 1000m)"
  type        = string
  default     = "1000m"
}

variable "memory_limit" {
  description = "The memory limit for the Cloud Run service (e.g., 512Mi)"
  type        = string
  default     = "512Mi"
}

variable "concurrency" {
  description = "The maximum number of concurrent requests per container instance"
  type        = number
  default     = 80
}

variable "min_instances" {
  description = "The minimum number of container instances"
  type        = number
  default     = 0
}

variable "max_instances" {
  description = "The maximum number of container instances"
  type        = number
  default     = 100
}

variable "timeout_seconds" {
  description = "The maximum time a request can take before timing out"
  type        = number
  default     = 300
}

variable "service_account_email" {
  description = "The email address of the service account to run the service as"
  type        = string
  default     = ""
}

variable "environment_variables" {
  description = "Environment variables to set for the container"
  type        = map(string)
  default     = {}
}

variable "cloudsql_connection_name" {
  description = "The connection name of the Cloud SQL instance to connect to"
  type        = string
  default     = ""
}

variable "public_access" {
  description = "Whether to make the service publicly accessible"
  type        = bool
  default     = true
}