resource "restapi_object" "firefly_oci_integration_request" {
  count  = var.skip_integration_request ? 0 : 1
  path   = "/integrations/oci?onConflictUpdate=true"
  data   = jsonencode(
    {
      "name"                       = var.tenancy_name,
      "accountNumber"              = var.tenancy_ocid,
      "userId"                     = var.user_ocid,
      "groupId"                    = var.group_ocid,
      "compartmentId"              = var.compartment_id,
      "region"                     = var.region,
      "eventDrivenRegions"         = var.event_driven_regions
      "isProd"                     = var.is_prod,
      "isEventDriven"              = var.eventdriven_enabled,
      "integrationSessionId"       = var.integration_session_id
      "managedServiceConnector"    = var.managed_service_connector
    }
  )
}

locals {
  response_obj = try(jsondecode(restapi_object.firefly_oci_integration_request[0].api_response), {})
  
  # Check if response has integration data or just a message (error case)
  has_integration = can(local.response_obj.integration)
  
  # Use conditional logic to handle both success and error responses
  user_ocid      = local.has_integration ? lookup(local.response_obj.integration, "userId", "") : ""
  public_key_raw = local.has_integration ? lookup(local.response_obj.integration, "publicKey", "") : ""
  public_key     = local.has_integration ? trimspace(local.public_key_raw) : ""
  fingerprint    = local.has_integration ? lookup(local.response_obj.integration, "fingerprint", "") : ""
  integration_id = local.has_integration ? lookup(local.response_obj.integration, "accountId", "") : ""
  
  # For debugging - expose the actual response structure
  response_message = lookup(local.response_obj, "message", "")
}
