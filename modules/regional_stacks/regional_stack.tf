# Regional Firefly OCI Integration Stack
# This configuration is deployed to each region via OCI Resource Manager

terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 5.0"
    }
  }
}

# Provider configuration for the specific region
provider "oci" {
  region = var.region
}

# Create regional Firefly integration resources
# This stack creates region-specific resources needed for Firefly integration

locals {
  common_tags = merge(var.tags, {
    "ManagedBy" = "Terraform"
    "Purpose"   = "Firefly-OCI-Integration"
    "Version"   = "1.0.0"
    "Region"    = var.region
    "StackType" = "Regional"
  })
}

# Regional audit logging configuration
resource "oci_logging_log_configuration" "regional_audit_config" {
  compartment_id = var.compartment_id
  display_name   = "firefly-regional-audit-config-${var.region}"
  log_group_id   = var.log_group_id
  
  # Configure regional audit log collection
  source {
    category    = "audit"
    resource    = var.tenancy_ocid
    service     = "audit"
    source_type = "OCISERVICE"
  }
  
  freeform_tags = local.common_tags
}

# Regional service connector for audit logs
resource "oci_sch_service_connector" "regional_connector" {
  compartment_id = var.compartment_id
  display_name   = "firefly-regional-connector-${var.region}"
  description    = "Regional Service Connector Hub for Firefly audit logs"
  
  # Source: Audit Log Group
  source {
    kind = "logging"
    log_sources {
      compartment_id = var.compartment_id
      log_group_id   = var.log_group_id
    }
  }
  
  # Target: OCI Stream
  target {
    kind = "streaming"
    stream_id = var.target_stream_id
  }
  
  # Tasks: Transform and filter logs
  tasks {
    kind = "logRule"
    condition = "true"  # Include all audit logs
  }
  
  freeform_tags = local.common_tags
}

# Regional IAM policies for the specific region
resource "oci_identity_policy" "regional_audit_policy" {
  compartment_id = var.compartment_id
  description    = "Regional policy for Firefly audit logging in ${var.region}"
  name           = "firefly-regional-audit-policy-${var.region}"
  statements = [
    "allow dynamic-group ${var.dynamic_group_id} to read audit-logs in tenancy",
    "allow dynamic-group ${var.dynamic_group_id} to manage log-configurations in compartment id ${var.compartment_id}",
    "allow dynamic-group ${var.dynamic_group_id} to read log-content in compartment id ${var.compartment_id}"
  ]
  freeform_tags = local.common_tags
}
