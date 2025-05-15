/**
 * Terraform backend configuration
 * Manages the state file for collaboration and consistency
 * 
 * Choose one of the following backend options:
 */

# Option 1: Google Cloud Storage backend
terraform {
  backend "gcs" {
    bucket = "terraform-state-php-app"  # Replace with your GCS bucket name
    prefix = "terraform/state"
  }
}

# Option 2: Terraform Cloud backend
# Uncomment and configure as needed
/*
terraform {
  backend "remote" {
    organization = "your-organization"
    
    workspaces {
      name = "php-app-infrastructure"
    }
  }
}
*/

# Option 3: Local backend (default, not recommended for production)
# Comment out the above backends to use local state