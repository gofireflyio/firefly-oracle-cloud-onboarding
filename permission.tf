resource "oci_identity_domains_user" "firefly_user" {
  count         = var.existing_user_id == null || var.existing_user_id == "" ? 1 : 0
  schemas       = ["urn:ietf:params:scim:schemas:core:2.0:User", "urn:ietf:params:scim:schemas:extension:enterprise:2.0:User"]
  idcs_endpoint = local.idcs_endpoint
  user_name     = local.user_name
  display_name  = local.user_name
  emails {
    value = local.user_email
    primary = true
    type = "work"
  }
  name {
    given_name = local.user_name
    family_name = local.user_name
  }
  urnietfparamsscimschemasoracleidcsextension_oci_tags {
    dynamic "freeform_tags" {
      for_each = local.common_tags
      content {
        key   = freeform_tags.key
        value = freeform_tags.value
      }
    }
  }
}

# # Create Dynamic Group for Firefly
resource "oci_identity_domains_group" "firefly_auth" {
  count         = var.existing_group_id == null || var.existing_group_id == "" ? 1 : 0
  idcs_endpoint = local.idcs_endpoint
  schemas       = ["urn:ietf:params:scim:schemas:core:2.0:Group"]
  display_name  = local.user_group_name

  # Add user to group
  members {
    value = var.existing_user_id != null && var.existing_user_id != "" ? var.existing_user_id : oci_identity_domains_user.firefly_user[0].id
    type  = "User"
  }

  urnietfparamsscimschemasoracleidcsextension_oci_tags {
    dynamic "freeform_tags" {
      for_each = local.common_tags
      content {
        key   = freeform_tags.key
        value = freeform_tags.value
      }
    }
  }
}

# # Create Dynamic Group for Firefly
resource "oci_identity_domains_dynamic_resource_group" "firefly_serviceconnector_group" {
  count          = var.existing_dynamic_group_id == "" ? 1 : 0
  idcs_endpoint = local.idcs_endpoint
  schemas       = ["urn:ietf:params:scim:schemas:oracle:idcs:DynamicResourceGroup"]
  display_name  = var.dynamic_group_name
  description    = "[DO NOT REMOVE] Dynamic group for service connector and stream"
  matching_rule  = "All {resource.type = 'serviceconnector', resource.compartment.id = '${local.compartment_id}'}"

  urnietfparamsscimschemasoracleidcsextension_oci_tags {
    dynamic "freeform_tags" {
      for_each = local.common_tags
      content {
        key   = freeform_tags.key
        value = freeform_tags.value
      }
    }
  }
}


# Policy for Service Connector Hub permissions
resource "oci_identity_policy" "firefly_auth_policy" {
  depends_on = [oci_identity_domains_group.firefly_auth]
  compartment_id = var.tenancy_ocid
  description    = "[DO NOT REMOVE] Policies required by Firefly User"
  name           = local.user_group_policy_name
  statements     = local.policy_statements
  freeform_tags  = local.common_tags
}


# resource "oci_identity_user_group_membership" "firefly_user_group_membership" {
#   depends_on = [module.firefly_oci_integration]
#   group_id = oci_identity_group.firefly_auth.id
#   user_id = oci_identity_user.firefly_user.id
# }

# Create API key from the public key returned by the Firefly integration API
# This is only created on the first apply when skip_integration_request = false
# For subsequent applies and destroy, set skip_integration_request = true
# resource "oci_identity_api_key" "firefly_user_api_key" {
#   count      = !var.skip_integration_request ? 1 : 0
#   depends_on = [module.firefly_oci_integration]
#   user_id    = oci_identity_user.firefly_user.id
#   key_value  = module.firefly_oci_integration.public_key

#   lifecycle {
#     create_before_destroy = false
#   }
# }

resource "oci_identity_domains_api_key" "firefly_user_api_key" {
  depends_on = [module.firefly_oci_integration, oci_identity_domains_user.firefly_user]
  count      = !var.skip_integration_request ? 1 : 0
  idcs_endpoint = local.idcs_endpoint
  schemas       = ["urn:ietf:params:scim:schemas:oracle:idcs:apikey"]
  key           = module.firefly_oci_integration.public_key
  
  user {
    ocid = oci_identity_domains_user.firefly_user[0].ocid
    value = oci_identity_domains_user.firefly_user[0].id
  }
}