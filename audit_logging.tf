# Create Log Group for Audit Logs
resource "oci_logging_log_group" "firefly_audit_logs" {
  count          = var.existing_log_group_id == "" ? 1 : 0
  compartment_id = var.compartment_id
  description    = "Log group for Firefly audit log collection"
  display_name   = local.log_group_name
  freeform_tags  = local.common_tags
}

# Enable Audit Logging Configuration
resource "oci_audit_configuration" "firefly_audit_config" {
  compartment_id = var.tenancy_ocid
  retention_period_days = 365
}

# Create Log Configuration for Audit Logs
resource "oci_logging_log_configuration" "firefly_audit_log_config" {
  compartment_id = var.compartment_id
  display_name   = "${local.name_prefix}firefly-audit-config${local.name_suffix}"
  log_group_id   = local.log_group_id
  
  # Configure audit log collection
  source {
    category    = "audit"
    resource    = var.tenancy_ocid
    service     = "audit"
    source_type = "OCISERVICE"
  }
  
  freeform_tags = local.common_tags
}
