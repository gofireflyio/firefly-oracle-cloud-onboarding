output "log_group_id" {
  description = "The OCID of the log group (either existing or newly created)"
  value       = var.existing_log_group_id != "" ? var.existing_log_group_id : oci_logging_log_group.firefly_audit_logs[0].id
}

output "log_configuration_id" {
  description = "The OCID of the log configuration"
  value       = oci_logging_log_configuration.firefly_audit_log_config.id
}

output "audit_configuration_id" {
  description = "The OCID of the audit configuration"
  value       = oci_audit_configuration.firefly_audit_config.id
}
