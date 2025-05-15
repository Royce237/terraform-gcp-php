/**
 * Variables for the main Terraform configuration
 * Defines inputs required for the PHP application infrastructure
 */

# Google Cloud Project variables
variable "project_id" {
  description = "The Google Cloud Project ID to deploy resources"
  type        = string
}

variable "project_name" {
  description = "The name of the Google Cloud Project (only used when creating a new project)"
  type        = string
  default     = "PHP Application"
}

variable "billing_account_id" {
  description = "The ID of the billing account to associate with the project (only used when creating a new project)"
  type        = string
  default     = ""
}

variable "region" {
  description = "The GCP region to deploy resources"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "The GCP zone within the region to deploy resources that require a zone"
  type        = string
  default     = "us-central1-a"
}

# Environment variables
variable "environment" {
  description = "The environment (dev, staging, production)"
  type        = string
  default     = "dev"
  
  validation {
    condition     = contains(["dev", "staging", "production"], var.environment)
    error_message = "Environment must be one of: dev, staging, production."
  }
}

# Application variables
variable "app_name" {
  description = "The name of the PHP application"
  type        = string
  default     = "php-app"
}

variable "container_image" {
  description = "The container image to deploy (e.g., gcr.io/my-project/php-app:latest)"
  type        = string
}

variable "app_cpu" {
  description = "The CPU limit for the Cloud Run service (e.g., 1000m)"
  type        = string
  default     = "1000m"
}

variable "app_memory" {
  description = "The memory limit for the Cloud Run service (e.g., 512Mi)"
  type        = string
  default     = "512Mi"
}

variable "app_concurrency" {
  description = "The maximum number of concurrent requests per container instance"
  type        = number
  default     = 80
}

variable "app_min_instances" {
  description = "The minimum number of container instances"
  type        = number
  default     = 0
}

variable "app_max_instances" {
  description = "The maximum number of container instances"
  type        = number
  default     = 100
}

# Database variables
variable "db_instance_name" {
  description = "The name of the Cloud SQL instance"
  type        = string
  default     = "php-app-mysql"
}

variable "db_name" {
  description = "The name of the MySQL database"
  type        = string
  default     = "php_app"
}

variable "db_version" {
  description = "The version of MySQL to use"
  type        = string
  default     = "MYSQL_8_0"
}

variable "db_tier" {
  description = "The machine type to use for the Cloud SQL instance"
  type        = string
  default     = "db-f1-micro"
}

variable "db_user" {
  description = "The username for the database"
  type        = string
  default     = "php_app_user"
}

variable "db_password" {
  description = "The password for the database user"
  type        = string
  sensitive   = true
}

# Load Balancer and domain variables
variable "domain_name" {
  description = "The domain name to use for the application"
  type        = string
  default     = ""
}

variable "ssl_certificate_id" {
  description = "The ID of the SSL certificate to use for HTTPS"
  type        = string
  default     = ""
}