output "service_connector_id" {
  description = "The OCID of the service connector"
  value       = oci_sch_service_connector.firefly_connector.id
}

output "service_connector_name" {
  description = "The display name of the service connector"
  value       = oci_sch_service_connector.firefly_connector.display_name
}
