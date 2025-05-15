#!/bin/bash

# get_cloud_run_ip.sh
# Script to retrieve the public IP address of a deployed Cloud Run service
# 
# Usage: ./get_cloud_run_ip.sh [environment]
# Example: ./get_cloud_run_ip.sh production
#
# Dependencies: gcloud CLI must be installed and authenticated

set -e  # Exit immediately if a command exits with a non-zero status

# Define log functions
log_info() {
  echo -e "\033[0;32m[INFO]\033[0m $1"
}

log_error() {
  echo -e "\033[0;31m[ERROR]\033[0m $1" >&2
}

log_warn() {
  echo -e "\033[0;33m[WARNING]\033[0m $1"
}

# Check if gcloud is installed
if ! command -v gcloud &> /dev/null; then
  log_error "gcloud CLI is not installed. Please install it first."
  exit 1
fi

# Check if user is authenticated with gcloud
if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" &> /dev/null; then
  log_error "You are not authenticated with gcloud. Please run 'gcloud auth login' first."
  exit 1
fi

# Default values
SERVICE_NAME="php-app"
REGION="us-central1"
ENV="development"

# Parse command line arguments
if [ $# -gt 0 ]; then
  ENV=$1
  
  # Adjust settings based on environment
  case $ENV in
    "production" | "prod")
      ENV="production"
      SERVICE_NAME="php-app-prod"
      log_info "Using production environment settings"
      ;;
    "staging" | "stage")
      ENV="staging"
      SERVICE_NAME="php-app-staging"
      log_info "Using staging environment settings"
      ;;
    "development" | "dev")
      ENV="development"
      SERVICE_NAME="php-app"
      log_info "Using development environment settings"
      ;;
    *)
      log_warn "Unknown environment '$ENV'. Using default settings."
      ENV="development"
      ;;
  esac
fi

# Create a log file with timestamp
LOG_FILE="cloud_run_ip_${ENV}_$(date +%Y%m%d_%H%M%S).log"
exec > >(tee -a "$LOG_FILE") 2>&1

log_info "Starting script to retrieve Cloud Run service IP for environment: $ENV"
log_info "Service name: $SERVICE_NAME"
log_info "Region: $REGION"

# Function to retrieve the Cloud Run service URL
get_service_url() {
  local service_name=$1
  local region=$2
  
  log_info "Retrieving service URL for $service_name in $region..."
  
  # Get the service URL
  local service_url
  service_url=$(gcloud run services describe "$service_name" \
    --region="$region" \
    --format="value(status.url)" 2>/dev/null) || return 1
  
  echo "$service_url"
}

# Function to resolve domain to IP address
resolve_ip() {
  local domain=$1
  
  log_info "Resolving IP address for domain: $domain"
  
  # Extract the hostname part from the URL (remove protocol)
  local hostname
  hostname=$(echo "$domain" | sed -e 's|^[^/]*//||' -e 's|/.*$||')
  
  # Resolve the IP address
  local ip_address
  ip_address=$(dig +short "$hostname" | head -n 1)
  
  if [ -z "$ip_address" ]; then
    log_error "Failed to resolve IP address for $hostname"
    return 1
  fi
  
  echo "$ip_address"
}

# Main execution
main() {
  # Get service URL
  local service_url
  service_url=$(get_service_url "$SERVICE_NAME" "$REGION")
  
  if [ -z "$service_url" ]; then
    log_error "Failed to retrieve service URL. Make sure the service '$SERVICE_NAME' exists in region '$REGION'."
    exit 1
  fi
  
  log_info "Service URL: $service_url"
  
  # Get IP address
  local ip_address
  ip_address=$(resolve_ip "$service_url")
  
  if [ -z "$ip_address" ]; then
    log_error "Failed to resolve IP address."
    exit 1
  fi
  
  log_info "Service IP Address: $ip_address"
  echo "$ip_address" > "${ENV}_service_ip.txt"
  log_info "IP address has been saved to ${ENV}_service_ip.txt"
}

# Execute main function with error handling
{
  main
} || {
  log_error "Script execution failed with error code $?"
  exit 1
}

log_info "Script completed successfully"