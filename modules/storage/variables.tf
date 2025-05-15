/**
 * Variables for the Cloud Storage module
 */

variable "project_id" {
  description = "The Google Cloud Project ID"
  type        = string
}

variable "bucket_name" {
  description = "The name of the Cloud Storage bucket"
  type        = string
}

variable "bucket_location" {
  description = "The location for the Cloud Storage bucket"
  type        = string
  default     = "US"
}

variable "force_destroy" {
  description = "Whether to delete all objects in the bucket when destroying"
  type        = bool
  default     = false
}

variable "lifecycle_age" {
  description = "The age in days after which objects should be managed by the lifecycle rule"
  type        = number
  default     = 90
}

variable "lifecycle_action" {
  description = "The lifecycle action to take (e.g., Delete, SetStorageClass)"
  type        = string
  default     = "Delete"
}

variable "enable_versioning" {
  description = "Whether to enable versioning for the bucket"
  type        = bool
  default     = false
}

variable "public_access" {
  description = "Whether to make the bucket publicly accessible"
  type        = bool
  default     = false
}

variable "cors_origins" {
  description = "List of origins for CORS"
  type        = list(string)
  default     = ["*"]
}

variable "create_service_account" {
  description = "Whether to create a service account for the bucket"
  type        = bool
  default     = false
}