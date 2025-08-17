# Create Dynamic Group for Firefly
resource "oci_identity_dynamic_group" "firefly_dynamic_group" {
  count          = var.existing_dynamic_group_id == "" ? 1 : 0
  compartment_id = var.tenancy_ocid
  description    = "Dynamic group for Firefly OCI integration"
  matching_rule  = "ALL {resource.type = 'auditlog'}"
  name           = local.dynamic_group_name
  freeform_tags  = local.common_tags
}

# Policy for Service Connector Hub permissions
resource "oci_identity_policy" "firefly_connector_hub_policy" {
  compartment_id = var.compartment_id
  description    = "Policy allowing Firefly to manage Service Connector Hub"
  name           = "${local.policy_name}-connector-hub"
  statements = [
    "allow dynamic-group ${local.dynamic_group_name} to manage service-connectors in compartment id ${var.compartment_id}",
    "allow dynamic-group ${local.dynamic_group_name} to read service-connectors in compartment id ${var.compartment_id}"
  ]
  freeform_tags = local.common_tags
}

# Policy for Audit Logging permissions
resource "oci_identity_policy" "firefly_audit_logging_policy" {
  compartment_id = var.compartment_id
  description    = "Policy allowing Firefly to read audit logs and manage log configurations"
  name           = "${local.policy_name}-audit-logging"
  statements = [
    "allow dynamic-group ${local.dynamic_group_name} to read audit-logs in tenancy",
    "allow dynamic-group ${local.dynamic_group_name} to manage log-groups in compartment id ${var.compartment_id}",
    "allow dynamic-group ${local.dynamic_group_name} to manage log-configurations in compartment id ${var.compartment_id}",
    "allow dynamic-group ${local.dynamic_group_name} to read log-content in compartment id ${var.compartment_id}"
  ]
  freeform_tags = local.common_tags
}

# Policy for Stream permissions
resource "oci_identity_policy" "firefly_stream_policy" {
  compartment_id = var.compartment_id
  description    = "Policy allowing Firefly to read from target stream"
  name           = "${local.policy_name}-stream"
  statements = [
    "allow dynamic-group ${local.dynamic_group_name} to read stream-family in compartment id ${var.compartment_id}",
    "allow dynamic-group ${local.dynamic_group_name} to read stream in compartment id ${var.compartment_id}"
  ]
  freeform_tags = local.common_tags
}
