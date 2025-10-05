data "http" "firefly_oci_integration_request" {
  url    = "${var.firefly_endpoint}/integrations/oci?onConflictUpdate=true"
  method = "POST"
  request_headers = {
    Content-Type  = "application/json"
    Authorization = "Bearer ${var.firefly_token}"
  }
  retry {
    attempts     = 3
    max_delay_ms = 5000
    min_delay_ms = 5000
  }
  request_body = jsonencode(
    {
      "name"                       = var.tenancy_name,
      "accountNumber"              = var.tenancy_ocid,
      "userId"                     = var.user_ocid,
      "region"                     = var.region
    }
  )
  # lifecycle {
  #   prevent_destroy = true
  # }
}

locals {
  response_obj = try(jsondecode(data.http.firefly_oci_integration_request.response_body), {})
  user_ocid    = lookup(local.response_obj.integration, "userId", "")
  public_key_raw   = lookup(local.response_obj.integration, "publicKey", "error")
  public_key = trimspace(local.public_key_raw)
  fingerprint  = lookup(local.response_obj.integration, "fingerprint", "error")
  integration_id = lookup(local.response_obj.integration, "accountId", "error")
  
}
