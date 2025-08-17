output "stack_digest" {
  description = "Unique identifier for this regional stack deployment"
  value       = random_id.stack_digest.hex
}

output "regional_stacks" {
  description = "Information about created regional stacks"
  value = {
    for region, stack in null_resource.regional_stacks_create_apply : region => {
      region_name = region
      stack_digest = random_id.stack_digest.hex
    }
  }
}

# Regional stack resource outputs
output "regional_audit_config_id" {
  description = "The OCID of the regional audit log configuration"
  value       = oci_logging_log_configuration.regional_audit_config.id
}

output "regional_connector_id" {
  description = "The OCID of the regional service connector"
  value       = oci_sch_service_connector.regional_connector.id
}

output "regional_audit_policy_id" {
  description = "The OCID of the regional audit policy"
  value       = oci_identity_policy.regional_audit_policy.id
}
