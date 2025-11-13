# Data sources for OCI resources

# Get current tenancy information
data "oci_identity_tenancy" "current" {
  tenancy_id = var.tenancy_ocid
}

# Get current region information
data "oci_identity_region_subscriptions" "current" {
  tenancy_id = var.tenancy_ocid
  provider   = oci.home
}

# Get all subscribed regions for multi-region service connector deployment
data "oci_identity_region_subscriptions" "all_regions" {
  tenancy_id = var.tenancy_ocid
  provider   = oci.home
}


# Get availability domains for the compartment
data "oci_identity_availability_domains" "ads" {
  compartment_id = var.tenancy_ocid
}

# Get current user's fingerprint and key info (if available)
data "oci_identity_api_keys" "current_user_keys" {
  count = var.current_user_ocid != "" ? 1 : 0
  user_id = var.current_user_ocid
}

# # Fetch actual stream ID from Firefly service using region endpoint
data "http" "firefly_stream_lookup" {
  count = var.managed_service_connector ? 0 : 1
  depends_on = [data.http.firefly_login]
  url = "${var.firefly_endpoint}/integrations/oci/stream-ids"
  method = "GET"
  request_headers = {
    Authorization = "Bearer ${local.token}"
  }
}


data "oci_identity_domains" "all_domains" {
  provider = oci.home
  compartment_id = var.tenancy_ocid
}

data "oci_identity_domains_user" "user_in_domain" {
  provider = oci.home
  for_each      = { for d in data.oci_identity_domains.all_domains.domains : d.id => d }
  idcs_endpoint = each.value.url
  user_id       = var.current_user_ocid
}

data "oci_identity_domains_user" "existing_user_in_domain" {
  for_each      = var.existing_user_id != null && var.existing_user_id != "" ? { for d in data.oci_identity_domains.all_domains.domains : d.id => d } : {}
  idcs_endpoint = each.value.url
  user_id       = var.existing_user_id
}

data "oci_identity_domains_groups" "existing_group_in_domain" {
  for_each      = var.existing_group_id != null && var.existing_group_id != "" ? { for d in data.oci_identity_domains.all_domains.domains : d.id => d } : {}
  idcs_endpoint = each.value.url
  group_filter  = "ocid eq \"${var.existing_group_id}\""
}

data "oci_identity_domain" "domain" {
  domain_id = local.matching_domain_id
}
