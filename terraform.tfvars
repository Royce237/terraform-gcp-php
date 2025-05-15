# Example values for the Terraform variables
# Copy this file to terraform.tfvars and update with your specific values

# Google Cloud Project
project_id = "my-php-application"
region     = "us-central1"
zone       = "us-central1-a"

# Environment
environment = "dev"

# Application
app_name        = "php-app"
container_image = "gcr.io/my-php-application/php-app:latest"
app_cpu         = "1000m"
app_memory      = "512Mi"
app_concurrency = 80
app_min_instances = 0
app_max_instances = 10

# Database
db_instance_name = "php-app-mysql"
db_name          = "php_app"
db_version       = "MYSQL_8_0"
db_tier          = "db-f1-micro"
db_user          = "php_app_user"
db_password      = "change-me-to-a-secure-password"

# Load Balancer and domain
domain_name       = "example.com"
ssl_certificate_id = ""  # Leave empty to create a new SSL certificate