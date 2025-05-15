/**
 * Cloud SQL Module
 * Creates a MySQL instance and database for the PHP application
 * 
 * Reference: https://cloud.google.com/sql/docs/mysql/terraform-instance-settings
 */

# Create a Cloud SQL instance
resource "google_sql_database_instance" "mysql_instance" {
  name             = var.instance_name
  database_version = var.database_version
  region           = var.region
  project          = var.project_id
  
  settings {
    tier              = var.database_tier
    availability_type = var.high_availability ? "REGIONAL" : "ZONAL"
    
    backup_configuration {
      enabled            = var.enable_backups
      binary_log_enabled = var.enable_backups
      start_time         = "02:00"  # 2 AM UTC
    }
    
    ip_configuration {
      ipv4_enabled    = false
      private_network = var.private_network_id != "" ? var.private_network_id : null
      
      # Allow connections from all IP addresses if private network is not set
      dynamic "authorized_networks" {
        for_each = var.private_network_id == "" ? [1] : []
        content {
          name  = "all"
          value = "0.0.0.0/0"
        }
      }
    }
    
    # Additional database flags
    database_flags {
      name  = "character_set_server"
      value = "utf8mb4"
    }
    
    database_flags {
      name  = "collation_server"
      value = "utf8mb4_unicode_ci"
    }

    # Enable point-in-time recovery for production environments
    dynamic "backup_configuration" {
      for_each = var.enable_point_in_time_recovery ? [1] : []
      content {
        enabled                        = true
        point_in_time_recovery_enabled = true
        start_time                     = "02:00"  # 2 AM UTC
        binary_log_enabled             = true
      }
    }
    
    maintenance_window {
      day          = 7  # Sunday
      hour         = 3  # 3 AM
      update_track = "stable"
    }
  }
  
  deletion_protection = var.deletion_protection
  
  # Increase timeout for instance creation
  timeouts {
    create = "60m"
    update = "60m"
    delete = "60m"
  }
}

# Create a database within the Cloud SQL instance
resource "google_sql_database" "database" {
  name      = var.database_name
  instance  = google_sql_database_instance.mysql_instance.name
  charset   = "utf8mb4"
  collation = "utf8mb4_unicode_ci"
  project   = var.project_id
}

# Create a user for the database
resource "google_sql_user" "user" {
  name     = var.database_user
  instance = google_sql_database_instance.mysql_instance.name
  password = var.database_password
  project  = var.project_id
}