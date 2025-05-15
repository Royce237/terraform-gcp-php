# PHP Application Deployment on Google Cloud Platform

This repository contains infrastructure as code (Terraform), CI/CD pipeline configuration, and deployment scripts for a PHP application running on Google Cloud Platform.

## Architecture Overview

This project deploys a PHP-FPM application with Nginx on Google Cloud Platform using the following resources:

- **Cloud Run**: Hosts the containerized PHP application with Nginx
- **Cloud SQL**: MySQL database for the application
- **Cloud Storage**: Bucket for static assets
- **Cloud Load Balancing**: Routes traffic to the Cloud Run service

![Architecture Diagram](https://via.placeholder.com/800x400?text=PHP+Application+Architecture)

## Prerequisites

Before you begin, ensure you have the following:

- [Google Cloud SDK](https://cloud.google.com/sdk/docs/install) installed and configured
- [Terraform](https://www.terraform.io/downloads.html) (v1.0.0 or later)
- [Git](https://git-scm.com/downloads)
- [Docker](https://docs.docker.com/get-docker/) (for local development and testing)
- A Google Cloud Platform account with billing enabled
- A Google Cloud project (or create one using Terraform)

## Repository Structure

```
.
|-- README.md
|-- app
|   |-- dockerfile               # Docker configuration for PHP-FPM and Nginx
|   |-- nginx.conf               # Nginx configuration
|   |-- public
|   |   `-- index.php            # Sample PHP application
|   `-- supervisord.conf         # Process management configuration
`-- terraform
    |-- backend.tf               # Terraform state configuration
    |-- main.tf                  # Main Terraform configuration
    |-- modules                  # Reusable Terraform modules
    |   |-- cloudrun             # Cloud Run service module
    |   |-- cloudsql             # Cloud SQL database module
    |   |-- loadbalancer         # Load balancer module
    |   `-- storage              # Cloud Storage bucket module
    |-- outputs.tf               # Terraform outputs
    |-- terraform.tfvars         # Environment-specific variables
    `-- variables.tf             # Variable declarations
```

## Setup Instructions

### 1. Configure Environment Variables

#### For Terraform

Create a `terraform.tfvars` file in the `/terraform` directory with the following variables:

```hcl
project_id          = "your-gcp-project-id"
region              = "us-central1"
db_name             = "php_app_db"
db_user             = "app_user"
db_password         = "your-secure-password"
storage_bucket_name = "your-app-static-assets"
```

#### For Local Development

Create a `.env` file in the root directory:

```
DB_HOST=localhost
DB_NAME=php_app_db
DB_USER=app_user
DB_PASSWORD=your-secure-password
```

### 2. Initialize and Apply Terraform Configuration

```bash
# Navigate to the terraform directory
cd terraform

# Initialize Terraform
terraform init

# Preview the changes
terraform plan

# Apply the configuration
terraform apply
```

### 3. Deploy the Application

You can deploy the application either manually or through the GitHub Actions CI/CD pipeline.

#### Manual Deployment

```bash
# Build the Docker image
docker build -t gcr.io/your-project-id/php-app:latest ./app

# Push to Google Container Registry
docker push gcr.io/your-project-id/php-app:latest

# Deploy to Cloud Run
gcloud run deploy php-app \
  --image gcr.io/your-project-id/php-app:latest \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated
```

#### CI/CD Pipeline (GitHub Actions)

The GitHub Actions workflow will automatically deploy your application when you push to the main branch.

To set up the CI/CD pipeline:

1. Add the following secrets to your GitHub repository:
   - `GCP_PROJECT_ID`: Your Google Cloud project ID
   - `GCP_SA_KEY`: Service account key JSON (base64 encoded)
   - `DB_HOST`: Cloud SQL instance connection name
   - `DB_NAME`: Database name
   - `DB_USER`: Database username
   - `DB_PASSWORD`: Database password

2. Push your code to the main branch:
   ```bash
   git add .
   git commit -m "Update application code"
   git push origin main
   ```

### 4. Access the Deployed Application

After deployment, you can access the application using the Cloud Run service URL:

```bash
gcloud run services describe php-app --region us-central1 --format='value(status.url)'
```

Or by using the load balancer IP address that's configured.

### 5. Retrieve the Public IP Address

Use the provided Bash script to retrieve the public IP address of your Cloud Run service:

```bash
# Make the script executable
chmod +x get_cloud_run_ip.sh

# Run for development environment (default)
./get_cloud_run_ip.sh

# Or specify an environment
./get_cloud_run_ip.sh production
```

The script will output the IP address and save it to a file in the current directory.

## Troubleshooting

### Common Issues and Solutions

#### Terraform State Locking

If you encounter state locking issues:

```bash
terraform force-unlock LOCK_ID
```

#### Cloud Run Deployment Failures

Check the deployment logs:

```bash
gcloud run services logs read php-app --region us-central1
```

#### Database Connection Issues

Verify that the Cloud SQL instance is properly configured and the connection string is correct:

```bash
# Check Cloud SQL instance status
gcloud sql instances describe your-sql-instance

# Verify network connectivity
gcloud sql instances patch your-sql-instance --authorized-networks=YOUR_IP_ADDRESS/32
```

#### GitHub Authentication Issues

If you encounter permission issues when pushing to GitHub:

1. Verify your Git configuration:
   ```bash
   git config user.name
   git config user.email
   ```

2. Update your Git credentials or use SSH:
   ```bash
   # Using SSH
   git remote set-url origin git@github.com:Royce237/terraform-gcp-php.git
   ```

#### Docker Build Errors

If Docker build fails:

```bash
# Check Docker daemon status
docker info

# Build with verbose output
docker build --no-cache -t gcr.io/your-project-id/php-app:latest ./app
```

## Challenges Encountered and Solutions

### 1. Cloud SQL Connection from Cloud Run

**Challenge**: Establishing a secure connection between Cloud Run and Cloud SQL required additional configuration.

**Solution**: Used the Cloud SQL Auth Proxy and implemented proper IAM permissions for the Cloud Run service account to access the Cloud SQL instance.

### 2. GitHub Authentication with Multiple Accounts

**Challenge**: Encountered permission issues when pushing to GitHub with different accounts configured.

**Solution**: Used SSH keys with specific configurations to manage multiple GitHub accounts properly.

### 3. Environment Variable Management

**Challenge**: Securely managing environment variables across different environments.

**Solution**: Used GitHub Secrets for CI/CD, Terraform variables for infrastructure, and implemented Secret Manager for sensitive data in production.

## Production Readiness Enhancements

For a production-ready environment, consider implementing the following additional features:

### 1. Monitoring and Logging

- Set up Cloud Monitoring alerts for service performance and errors
- Implement structured logging with Cloud Logging
- Create custom dashboards for key metrics

### 2. Security Enhancements

- Implement Web Application Firewall (WAF) with Cloud Armor
- Configure VPC Service Controls
- Set up regular security scanning and vulnerability assessment
- Implement proper IAM roles with least privilege principles

### 3. Backup and Disaster Recovery

- Set up automated database backups
- Implement a disaster recovery plan with multi-region failover
- Perform regular restore testing

### 4. Performance Optimization

- Configure Cloud CDN for static assets
- Implement caching strategies
- Set up auto-scaling policies based on load

### 5. CI/CD Improvements

- Add integration and end-to-end testing
- Implement blue-green or canary deployments
- Set up approval workflows for production deployments

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Contributors

- Royce - Initial implementation and documentation
