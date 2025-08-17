terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 5.0"
    }
  }
}

# Create Log Group for Audit Logs
resource "oci_logging_log_group" "firefly_audit_logs" {
  count          = var.existing_log_group_id == "" ? 1 : 0
  compartment_id = var.compartment_id
  description    = "Log group for Firefly audit log collection"
  display_name   = "firefly-audit-logs"
  freeform_tags  = var.tags
}

# Enable Audit Logging Configuration
resource "oci_audit_configuration" "firefly_audit_config" {
  compartment_id = var.tenancy_ocid
  retention_period_days = 365
}

# Create Log Configuration for Audit Logs
resource "oci_logging_log_configuration" "firefly_audit_log_config" {
  compartment_id = var.compartment_id
  display_name   = "firefly-audit-config"
  log_group_id   = local.log_group_id
  
  # Configure audit log collection
  source {
    category    = "audit"
    resource    = var.tenancy_ocid
    service     = "audit"
    source_type = "OCISERVICE"
  }
  
  freeform_tags = var.tags
}

locals {
  log_group_id = var.existing_log_group_id != "" ? var.existing_log_group_id : oci_logging_log_group.firefly_audit_logs[0].id
}
