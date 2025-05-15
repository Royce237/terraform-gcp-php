/**
 * Cloud Run Module
 * Deploys a containerized PHP-FPM application with Nginx
 * 
 * Reference: https://cloud.google.com/run/docs/terraform
 */

# Create the Cloud Run service
resource "google_cloud_run_service" "php_app" {
  name     = var.service_name
  location = var.region
  project  = var.project_id
  
  template {
    spec {
      containers {
        image = var.container_image
        
        # Set resource limits
        resources {
          limits = {
            cpu    = var.cpu_limit
            memory = var.memory_limit
          }
        }
        
        # Set container port
        ports {
          container_port = var.container_port
        }
        
        # Set environment variables
        dynamic "env" {
          for_each = var.environment_variables
          content {
            name  = env.key
            value = env.value
          }
        }
        
        # Set Cloud SQL connection if provided
        dynamic "env" {
          for_each = var.cloudsql_connection_name != "" ? [1] : []
          content {
            name  = "CLOUDSQL_INSTANCE"
            value = var.cloudsql_connection_name
          }
        }
      }
      
      # Set concurrency
      container_concurrency = var.concurrency
      
      # Set service account if provided
      service_account_name = var.service_account_email
      
      # Set timeouts
      timeout_seconds = var.timeout_seconds
    }
    
    metadata {
      annotations = {
        "autoscaling.knative.dev/minScale"      = var.min_instances
        "autoscaling.knative.dev/maxScale"      = var.max_instances
        "run.googleapis.com/cloudsql-instances" = var.cloudsql_connection_name
        "run.googleapis.com/client-name"        = "terraform"
      }
    }
  }
  
  # Set traffic distribution
  traffic {
    percent         = 100
    latest_revision = true
  }
  
  # Set auto-scaling settings
  autogenerate_revision_name = true
  
  # Increase timeout for service creation
  timeouts {
    create = "10m"
    update = "10m"
    delete = "5m"
  }
}

# Set IAM policy to make the service publicly accessible
resource "google_cloud_run_service_iam_member" "public_access" {
  count    = var.public_access ? 1 : 0
  service  = google_cloud_run_service.php_app.name
  location = google_cloud_run_service.php_app.location
  role     = "roles/run.invoker"
  member   = "allUsers"
}