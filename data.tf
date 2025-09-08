# Data sources for OCI resources

# Get current tenancy information
data "oci_identity_tenancy" "current" {
  tenancy_id = var.tenancy_ocid
}

# Get current compartment information
# data "oci_identity_compartment" "current" {
#   id = local.compartment_id
# }

# Get current user information (if available)
data "oci_identity_user" "current" {
  count = var.user_ocid != "" ? 1 : 0
  user_id = var.user_ocid
}

# Get current region information
data "oci_identity_region_subscriptions" "current" {
  tenancy_id = var.tenancy_ocid
  filter {
    name   = "region_name"
    values = [var.region]
  }
}

# Get existing log group if specified
data "oci_logging_log_group" "existing_log_group" {
  count = var.existing_log_group_id != "" ? 1 : 0
  log_group_id = var.existing_log_group_id
}

# Get availability domains for the compartment
data "oci_identity_availability_domains" "ads" {
  compartment_id = var.tenancy_ocid
}

# Get current user's fingerprint and key info (if available)
data "oci_identity_api_keys" "current_user_keys" {
  count = var.user_ocid != "" ? 1 : 0
  user_id = var.user_ocid
}

# # Fetch actual stream ID from Firefly service using region endpoint
data "http" "firefly_stream_lookup" {
  depends_on = [data.http.firefly_login]
  url = "${var.firefly_endpoint}/integrations/oci/stream-ids"
  method = "GET"
  request_headers = {
    Authorization = "Bearer ${local.token}"
  }
}


data "oci_identity_domains" "all_domains" {
  compartment_id = var.tenancy_ocid
}

data "oci_identity_domains_user" "user_in_domain" {
  for_each      = { for d in data.oci_identity_domains.all_domains.domains : d.id => d }
  idcs_endpoint = each.value.url
  user_id       = var.user_ocid
}

data "oci_identity_domain" "domain" {
  domain_id = local.matching_domain_id
}