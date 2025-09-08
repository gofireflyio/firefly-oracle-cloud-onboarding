output "module_name" {
  description = "Name of the Firefly OCI integration module"
  value       = "firefly_oci_integration"
}

output "module_version" {
  description = "Version of the Firefly OCI integration module"
  value       = "1.0.0"
}

output "user_ocid" {
  description = "OCI User OCID"
  value       = local.user_ocid
}

output "public_key" {
  description = "OCI Public Key"
  value       = local.public_key
}

output "fingerprint" {
  description = "OCI Fingerprint"
  value       = local.fingerprint
}

output "integration_id" {
  description = "OCI Integration ID"
  value       = local.integration_id
}

output "status_code" {
  value = data.http.firefly_oci_integration_request.status_code
}
output "response_body" {
  value = data.http.firefly_oci_integration_request.response_body
}

output "request_body" {
  value = data.http.firefly_oci_integration_request.request_body
}