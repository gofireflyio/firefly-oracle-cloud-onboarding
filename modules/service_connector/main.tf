terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 5.0"
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
      log_group_id   = var.log_group_id
    }
  }
  
  # Target: OCI Stream (configurable via variable)
  target {
    kind = "streaming"
    stream_id = var.target_stream_id
  }
  
  # Tasks: Transform and filter logs
  tasks {
    kind = "logRule"
    condition = "true"  # Include all audit logs
  }
  
  freeform_tags = var.tags
}
