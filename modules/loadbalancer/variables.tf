/**
 * Variables for the Load Balancer module
 */

variable "project_id" {
  description = "The Google Cloud Project ID"
  type        = string
}

variable "region" {
  description = "The GCP region for the serverless NEG"
  type        = string
}

variable "name" {
  description = "The base name for load balancer resources"
  type        = string
}

variable "cloud_run_service" {
  description = "The name of the Cloud Run service to route traffic to"
  type        = string
}

variable "ssl_certificate" {
  description = "The ID of the SSL certificate to use for HTTPS"
  type        = string
  default     = ""
}

variable "domain_name" {
  description = "The domain name to use for the load balancer"
  type        = string
  default     = ""
}

variable "enable_cdn" {
  description = "Whether to enable Cloud CDN for the load balancer"
  type        = bool
  default     = false
}

variable "enable_http" {
  description = "Whether to enable HTTP access in addition to HTTPS"
  type        = bool
  default     = true
}