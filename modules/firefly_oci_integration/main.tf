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
    }
  )
}
