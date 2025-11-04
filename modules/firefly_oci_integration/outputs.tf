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
  value = try(restapi_object.firefly_oci_integration_request[0].id, null)
}
output "response_body" {
  value = try(restapi_object.firefly_oci_integration_request[0].api_response, null)
}

output "request_body" {
  value = try(restapi_object.firefly_oci_integration_request[0].data, null)
}