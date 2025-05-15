/**
 * Load Balancer Module
 * Configures a Cloud Load Balancer to route traffic to the Cloud Run service
 * 
 * Reference: https://cloud.google.com/load-balancing/docs/https/setup-global-ext-https-serverless
 */

# Create a global external IP address
resource "google_compute_global_address" "default" {
  name    = "${var.name}-address"
  project = var.project_id
}

# Create the serverless NEG to connect to Cloud Run
resource "google_compute_region_network_endpoint_group" "serverless_neg" {
  name                  = "${var.name}-neg"
  network_endpoint_type = "SERVERLESS"
  region                = var.region
  project               = var.project_id
  
  cloud_run {
    service = var.cloud_run_service
  }
}

# Create a backend service for the load balancer
resource "google_compute_backend_service" "default" {
  name                  = "${var.name}-backend"
  project               = var.project_id
  load_balancing_scheme = "EXTERNAL_MANAGED"
  protocol              = "HTTP"
  port_name             = "http"
  timeout_sec           = 30
  enable_cdn            = var.enable_cdn
  
  backend {
    group = google_compute_region_network_endpoint_group.serverless_neg.id
  }
  
  # Configure CDN if enabled
  dynamic "cdn_policy" {
    for_each = var.enable_cdn ? [1] : []
    content {
      cache_mode        = "CACHE_ALL_STATIC"
      client_ttl        = 3600
      default_ttl       = 3600
      max_ttl           = 86400
      serve_while_stale = 86400
      
      # Configure cache keys
      cache_key_policy {
        include_host           = true
        include_protocol       = true
        include_query_string   = true
        query_string_whitelist = ["v", "version"]
      }
    }
  }
}

# Create URL map to route requests to the backend service
resource "google_compute_url_map" "default" {
  name            = "${var.name}-url-map"
  project         = var.project_id
  default_service = google_compute_backend_service.default.id
}

# Create HTTPS target proxy if SSL certificate is provided
resource "google_compute_target_https_proxy" "https_proxy" {
  count   = var.ssl_certificate != "" ? 1 : 0
  name    = "${var.name}-https-proxy"
  project = var.project_id
  url_map = google_compute_url_map.default.id
  
  ssl_certificates = [var.ssl_certificate]
}

# Create HTTP target proxy if no SSL certificate is provided or if HTTP is enabled
resource "google_compute_target_http_proxy" "http_proxy" {
  count   = var.ssl_certificate == "" || var.enable_http ? 1 : 0
  name    = "${var.name}-http-proxy"
  project = var.project_id
  url_map = google_compute_url_map.default.id
}

# Create forwarding rule for HTTPS traffic
resource "google_compute_global_forwarding_rule" "https" {
  count                 = var.ssl_certificate != "" ? 1 : 0
  name                  = "${var.name}-https-rule"
  project               = var.project_id
  target                = google_compute_target_https_proxy.https_proxy[0].id
  port_range            = "443"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  ip_address            = google_compute_global_address.default.id
}

# Create forwarding rule for HTTP traffic (either as main or for redirects)
resource "google_compute_global_forwarding_rule" "http" {
  count                 = var.ssl_certificate == "" || var.enable_http ? 1 : 0
  name                  = "${var.name}-http-rule"
  project               = var.project_id
  target                = google_compute_target_http_proxy.http_proxy[0].id
  port_range            = "80"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  ip_address            = google_compute_global_address.default.id
}