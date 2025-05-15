PHP Application Infrastructure on Google Cloud Platform
This repository contains Terraform configuration for deploying a PHP application on Google Cloud Platform using the following services:

Cloud SQL (MySQL database)
Cloud Storage (for static files)
Cloud Run (for containerized PHP-FPM with Nginx)
Cloud Load Balancing (HTTP/HTTPS)

Architecture
The infrastructure follows a modern serverless architecture:

Cloud Run hosts the PHP application using containerized PHP-FPM and Nginx
Cloud SQL provides a managed MySQL database
Cloud Storage stores static assets (images, CSS, JS, etc.)
Cloud Load Balancing routes traffic to the Cloud Run service and provides SSL termination

Prerequisites

Terraform v1.0.0+
Google Cloud SDK
A Google Cloud Platform account with billing enabled
Docker installed locally for building the application container image

Project Structure
.
├── main.tf             # Main Terraform configuration
├── variables.tf        # Input variables
├── outputs.tf          # Output values
├── terraform.tfvars    # Variable values (create from terraform.tfvars.example)
├── backend.tf          # Terraform state configuration
├── modules/            # Reusable Terraform modules
│   ├── cloudsql/       # Cloud SQL module
│   ├── storage/        # Cloud Storage module
│   ├── cloudrun/       # Cloud Run module
│   └── loadbalancer/   # Load Balancer module
└── app/                # Application files
    ├── Dockerfile      # Dockerfile for PHP-FPM and Nginx
    ├── nginx.conf      # Nginx configuration
    ├── supervisord.conf # Supervisor configuration for running both services
    └── public/         # PHP application files
        └── index.php   # Sample PHP script
Setup and Deployment
1. Authenticate with Google Cloud
bashgcloud auth login
gcloud auth application-default login
2. Configure Variables
Copy the example variable file and update with your values:
bashcp terraform.tfvars.example terraform.tfvars
Edit terraform.tfvars to set your project ID, region, and other configuration values.
3. Build and Push the Container Image
bash# Build the container image
docker build -t gcr.io/[PROJECT_ID]/php-app:latest ./app

# Configure Docker to use gcloud for authentication
gcloud auth configure-docker

# Push the image to Google Container Registry
docker push gcr.io/[PROJECT_ID]/php-app:latest
4. Initialize Terraform
bashterraform init
5. Plan and Apply
bashterraform plan
terraform apply
State Management
This project is configured to store Terraform state in Google Cloud Storage for team collaboration. The backend.tf file contains the configuration.
To create the GCS bucket for state storage:
bashgsutil mb -l [REGION] gs://terraform-state-php-app
gsutil versioning set on gs://terraform-state-php-app
Module Documentation
Cloud SQL Module
Creates a MySQL database instance with appropriate settings for your application.
Key Features:

Configurable instance type and MySQL version
Optional high availability configuration
Backup configuration with optional point-in-time recovery
Private networking support

Cloud Storage Module
Creates a bucket for storing static assets with appropriate permissions.
Key Features:

CORS configuration for web access
Lifecycle policies for object management
Optional CDN configuration
Optional public access or service account access

Cloud Run Module
Deploys a containerized PHP application with Nginx as a sidecar.
Key Features:

Configurable CPU and memory allocation
Min/max instance configuration for autoscaling
Environment variable management
Cloud SQL connection configuration

Load Balancer Module
Configures a global HTTP/HTTPS load balancer to route traffic to the Cloud Run service.
Key Features:

SSL certificate management
Optional CDN configuration
Global IP address allocation
HTTP to HTTPS redirection

Maintenance and Updates
Updating the Application

Build a new container image with a new tag
Push the image to Google Container Registry
Update the container_image variable in terraform.tfvars
Run terraform apply

Scaling the Infrastructure
To scale the application:

Adjust the app_min_instances and app_max_instances variables
Update the app_cpu and app_memory variables as needed
Run terraform apply

References

https://cloud.google.com/run/docs
https://cloud.google.com/sql/docs
https://cloud.google.com/storage/docs
https://registry.terraform.io/providers/hashicorp/google/latest/docs


Documentation for GitHub Actions CI/CD Pipeline
The GitHub Actions workflow I've created handles the complete CI/CD pipeline for your PHP application. Here's a breakdown of how it works:

Workflow Triggers:

Runs on pushes to main/master branches
Runs on pull requests targeting main/master branches


Test Job:

Sets up PHP environment
Installs dependencies using Composer (if composer.json exists)
Runs PHPUnit tests (if available)


Build and Deploy Job:

Runs after tests pass
Sets up Google Cloud SDK
Authenticates with Google Cloud
Builds Docker image from your Dockerfile
Pushes image to Google Artifact Registry
Deploys to Cloud Run with environment variables
Outputs the service URL


Environment Variables and Secrets:

GCP_PROJECT_ID: Your Google Cloud project ID
GCP_SA_KEY: Service account key for authentication
Database credentials: DB_HOST, DB_NAME, DB_USER, DB_PASSWORD



To use this workflow, you'll need to:

Create these secrets in your GitHub repository settings
Ensure your service account has appropriate permissions
Push this file to .github/workflows/deploy.yml in your repository

Documentation for Bash Script
The Bash script get_cloud_run_ip.sh is designed to retrieve the public IP address of your deployed Cloud Run service. Here's how it works:

Command-line Arguments:

Takes an optional environment parameter (development, staging, production)
Adapts service name based on the environment


Error Handling:

Checks if gcloud CLI is installed
Verifies the user is authenticated
Uses proper error trapping and logging


Core Functionality:

Retrieves the Cloud Run service URL using gcloud CLI
Resolves the URL to an IP address using dig
Saves the IP address to a file


Logging:

Creates a timestamped log file for each run
Uses colored output for different log levels
Provides clear error messages



To use this script:

Make it executable: chmod +x get_cloud_run_ip.sh
Run it: ./get_cloud_run_ip.sh [environment]
Find the IP address in both the output and the saved file