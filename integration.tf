# Validate required variables and configurations
resource "null_resource" "firefly_validation" {
  provisioner "local-exec" {
    when       = create
    on_failure = fail
    command = <<-EOT
      # Validate required variables
      if [ -z "${var.firefly_access_key}" ]; then
        echo "ERROR: firefly_access_key is required"
        exit 1
      fi
      
      if [ -z "${var.firefly_secret_key}" ]; then
        echo "ERROR: firefly_secret_key is required"
        exit 1
      fi
      
      echo "✅ Firefly validation passed"
    EOT
  }

  triggers = {
    firefly_access_key = var.firefly_access_key
    firefly_secret_key = var.firefly_secret_key
  }
}

data "http" "firefly_login" {
  depends_on = [null_resource.firefly_validation]
  count  = var.firefly_secret_key != "" ? 1 : 0
  url    = "${var.firefly_endpoint}/account/access_keys/login"
  method = "POST"
  request_headers = {
    Content-Type = "application/json"
  }
  request_body = jsonencode({ "accessKey" = var.firefly_access_key, "secretKey" = var.firefly_secret_key })
}

locals {
  response_obj = try(jsondecode(data.http.firefly_login[0].response_body), {})
  token        = lookup(local.response_obj, "access_token", "error")
}


# Firefly OCI Integration
module "firefly_oci_integration" {

  depends_on = [ oci_identity_domains_user.firefly_user, data.http.firefly_login]
  source = "./modules/firefly_oci_integration"

  firefly_endpoint          = var.firefly_endpoint
  firefly_token             = local.token
  tenancy_ocid              = var.tenancy_ocid
  compartment_id            = local.compartment_id
  region                    = var.region
  event_driven_regions      = var.event_driven_regions
  is_prod                   = var.is_prod
  tenancy_name              = data.oci_identity_tenancy.current.name
  user_ocid                 = oci_identity_domains_user.firefly_user[0].ocid
  group_ocid                = oci_identity_domains_dynamic_resource_group.firefly_serviceconnector_group[0].ocid
  integration_session_id    = var.integration_session_id
  managed_service_connector = var.managed_service_connector
  skip_integration_request  = var.skip_integration_request
  tags                      = var.tags
}

output "status_code" {
  value = module.firefly_oci_integration.status_code
}
output "response_body" {
  value = module.firefly_oci_integration.response_body
}