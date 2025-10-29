resource "oci_identity_user" "firefly_user" {
  compartment_id = var.tenancy_ocid
  description    = "Firefly user"
  name           = local.user_name
  email          = local.user_email
  freeform_tags  = local.common_tags
}

resource "oci_identity_group" "firefly_auth" {
  compartment_id = var.tenancy_ocid
  description    = "Firefly group"
  name           = local.user_group_name
  freeform_tags  = local.common_tags
}


# # Create Dynamic Group for Firefly
resource "oci_identity_dynamic_group" "firefly_serviceconnector_group" {
  count          = var.existing_dynamic_group_id == "" ? 1 : 0
  compartment_id = var.tenancy_ocid
  description    = "[DO NOT REMOVE] Dynamic group for service connector and stream"
  matching_rule  = "All {resource.type = 'serviceconnector', resource.compartment.id = '${local.compartment_id}'}"
  name           = var.dynamic_group_name
  freeform_tags  = local.common_tags
}

# Policy for Service Connector Hub permissions
resource "oci_identity_policy" "firefly_auth_policy" {
  depends_on = [oci_identity_group.firefly_auth]
  compartment_id = var.tenancy_ocid
  description    = "[DO NOT REMOVE] Policies required by Firefly User"
  name           = local.user_group_policy_name
  statements = [
    "Define tenancy Firefly as ocid1.tenancy.oc1..aaaaaaaahxrxe37ndpd3xidrt4laffdtxhdaq4srccux3cumrugervil4inq",
    "Allow dynamic-group ${oci_identity_dynamic_group.firefly_serviceconnector_group[0].name} to read audit-events in tenancy",
    "Allow dynamic-group ${oci_identity_dynamic_group.firefly_serviceconnector_group[0].name} to read logging-family in tenancy",
    "Endorse dynamic-group ${oci_identity_dynamic_group.firefly_serviceconnector_group[0].name} to {STREAM_READ, STREAM_PRODUCE} in tenancy Firefly",
  ]
  freeform_tags = local.common_tags
}


resource "oci_identity_user_group_membership" "firefly_user_group_membership" {
  depends_on = [module.firefly_oci_integration]
  group_id = oci_identity_group.firefly_auth.id
  user_id = oci_identity_user.firefly_user.id
}

# Create API key from the public key returned by the Firefly integration API
# This is only created on the first apply when skip_integration_request = false
# For subsequent applies and destroy, set skip_integration_request = true
resource "oci_identity_api_key" "firefly_user_api_key" {
  count      = !var.skip_integration_request ? 1 : 0
  depends_on = [module.firefly_oci_integration]
  user_id    = oci_identity_user.firefly_user.id
  key_value  = module.firefly_oci_integration.public_key

  lifecycle {
    create_before_destroy = false
  }
}