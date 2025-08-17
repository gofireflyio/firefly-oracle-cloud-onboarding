output "dynamic_group_id" {
  description = "The OCID of the dynamic group (either existing or newly created)"
  value       = var.existing_dynamic_group_id != "" ? var.existing_dynamic_group_id : oci_identity_dynamic_group.firefly_dynamic_group[0].id
}

output "dynamic_group_name" {
  description = "The name of the dynamic group"
  value       = var.existing_dynamic_group_id != "" ? var.existing_dynamic_group_id : oci_identity_dynamic_group.firefly_dynamic_group[0].name
}

output "connector_hub_policy_id" {
  description = "The OCID of the Service Connector Hub policy"
  value       = oci_identity_policy.firefly_connector_hub_policy.id
}

output "audit_logging_policy_id" {
  description = "The OCID of the audit logging policy"
  value       = oci_identity_policy.firefly_audit_logging_policy.id
}

output "stream_policy_id" {
  description = "The OCID of the stream policy"
  value       = oci_identity_policy.firefly_stream_policy.id
}
