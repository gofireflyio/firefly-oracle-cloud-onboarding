# Firefly API authentication
data "http" "firefly_login" {
  count  = var.firefly_secret_key != "" ? 1 : 0
  url    = "${var.firefly_endpoint}/account/access_keys/login"
  method = "POST"
  request_headers = {
    Content-Type = "application/json"
  }
  request_body = jsonencode({ 
    "accessKey" = var.firefly_access_key, 
    "secretKey" = var.firefly_secret_key 
  })
}

locals {
  response_obj = try(jsondecode(data.http.firefly_login[0].response_body), {})
  token        = lookup(local.response_obj, "access_token", "error")
}

# Firefly OCI Integration
module "firefly_oci_integration" {
  count = var.trigger_integrations ? 1 : 0
  
  source = "./modules/firefly_oci_integration"
  
  firefly_endpoint = var.firefly_endpoint
  firefly_token    = local.token
  tenancy_ocid     = var.tenancy_ocid
  compartment_id   = var.compartment_id
  region           = var.region
  prefix           = var.prefix
  suffix           = var.suffix
  tags             = var.tags
}
