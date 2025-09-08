terraform {
  required_version = ">= 1.5.0"
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">=7.1.0"
    }
  }
}

# Create Service Connector Hub to route audit logs
resource "oci_sch_service_connector" "firefly_connector" {
  compartment_id = var.compartment_id
  display_name   = "firefly-audit-connector"
  description    = "Service Connector Hub for routing Firefly audit logs to stream"
  
  # Source: Audit Log Group
  source {
    kind = "logging"
    log_sources {
      compartment_id = var.compartment_id
      log_group_id   = "_Audit_Include_Subcompartment"
    }
  }
  
  # Target: OCI Stream (configurable via variable)
  target {
    kind = "streaming"
    stream_id = var.target_stream_id
  }
  
  
  freeform_tags = var.tags
}
