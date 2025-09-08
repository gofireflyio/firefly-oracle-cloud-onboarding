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
  matching_rule  = "All {resource.type = 'serviceconnector'},"
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
    "Allow group id ${var.existing_group_id != null && var.existing_group_id != "" ? var.existing_group_id : oci_identity_group.firefly_auth.id} to read all-resources in tenancy",
    "Allow group id ${var.existing_group_id != null && var.existing_group_id != "" ? var.existing_group_id : oci_identity_group.firefly_auth.id} to manage serviceconnectors in compartment id ${var.tenancy_ocid}",
    "Endorse group id ${var.existing_group_id != null && var.existing_group_id != "" ? var.existing_group_id : oci_identity_group.firefly_auth.id} to use stream-push in tenancy Firefly where all { request.principal.type='serviceconnector', request.principal.compartment.id = '${var.tenancy_ocid}' }",
  ]
  freeform_tags = local.common_tags
}


resource "oci_identity_user_group_membership" "firefly_user_group_membership" {
  depends_on = [module.firefly_oci_integration]
  group_id = oci_identity_group.firefly_auth.id
  user_id = oci_identity_user.firefly_user.id
}

resource "oci_identity_api_key" "firefly_user_api_key" {
  depends_on = [module.firefly_oci_integration]
  user_id = oci_identity_user.firefly_user.id
  key_value = module.firefly_oci_integration.public_key

}