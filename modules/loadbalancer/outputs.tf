/**
 * Outputs from the Load Balancer module
 */

output "external_ip" {
  description = "The external IP address of the load balancer"
  value       = google_compute_global_address.default.address
}

output "external_ip_url" {
  description = "The URL using the external IP address"
  value       = "https://${google_compute_global_address.default.address}"
}

output "domain_url" {
  description = "The URL using the domain name (if provided)"
  value       = var.domain_name != "" ? "https://${var.domain_name}" : null
}

output "load_balancer_name" {
  description = "The name of the load balancer URL map"
  value       = google_compute_url_map.default.name
}

output "backend_service_name" {
  description = "The name of the backend service"
  value       = google_compute_backend_service.default.name
}