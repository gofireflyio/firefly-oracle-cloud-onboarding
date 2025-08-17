terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 5.0"
    }
  }
}

# Create Dynamic Group for Firefly
resource "oci_identity_dynamic_group" "firefly_dynamic_group" {
  count          = var.existing_dynamic_group_id == "" ? 1 : 0
  compartment_id = var.tenancy_id
  description    = "Dynamic group for Firefly OCI integration"
  matching_rule  = "ALL {resource.type = 'auditlog'}"
  name           = "firefly-dynamic-group"
  freeform_tags  = var.tags
}


resource "oci_identity_dynamic_group" "firefly_serviceconnector_group" {
  compartment_id = var.tenancy_id
  description    = "[DO NOT REMOVE] Dynamic group for service connector"
  matching_rule  = "All {resource.type = 'serviceconnector'}"
  name           = "firefly-serviceconnector-group"
  freeform_tags = var.tags
}

# # Policy for Service Connector Hub permissions
# resource "oci_identity_policy" "firefly_connector_hub_policy" {
#   compartment_id = var.compartment_id
#   description    = "Policy allowing Firefly to manage Service Connector Hub"
#   name           = "firefly-connector-hub-policy"
#   statements = [
#     "allow dynamic-group ${local.dynamic_group_name} to manage service-connectors in compartment id ${var.compartment_id}",
#     "allow dynamic-group ${local.dynamic_group_name} to read service-connectors in compartment id ${var.compartment_id}"
#   ]
#   freeform_tags = var.tags
# }

# Policy for Audit Logging permissions
resource "oci_identity_policy" "firefly_audit_logging_policy" {
  compartment_id = var.compartment_id
  description    = "Policy allowing Firefly to read audit logs and manage log configurations"
  name           = "firefly-audit-logging-policy"
  statements = [
    "allow dynamic-group ${local.dynamic_group_name} to read audit-logs in tenancy",
    "allow dynamic-group ${local.dynamic_group_name} to manage log-groups in compartment id ${var.compartment_id}",
    "allow dynamic-group ${local.dynamic_group_name} to manage log-configurations in compartment id ${var.compartment_id}",
    "allow dynamic-group ${local.dynamic_group_name} to read log-content in compartment id ${var.compartment_id}"
  ]
  freeform_tags = var.tags
}

# Policy for Stream permissions
resource "oci_identity_policy" "firefly_stream_policy" {
  compartment_id = var.compartment_id
  description    = "Policy allowing Firefly to read from target stream"
  name           = "firefly-stream-policy"
  statements = [
    "allow dynamic-group ${local.dynamic_group_name} to read stream-family in compartment id ${var.compartment_id}",
    "allow dynamic-group ${local.dynamic_group_name} to read stream in compartment id ${var.compartment_id}"
  ]
  freeform_tags = var.tags
}

locals {
  dynamic_group_name = var.existing_dynamic_group_id != "" ? var.existing_dynamic_group_id : oci_identity_dynamic_group.firefly_dynamic_group[0].name
}
