# Data sources for OCI resources

# Get current tenancy information
data "oci_identity_tenancy" "current" {
  tenancy_id = var.tenancy_ocid
}

# Get current compartment information
data "oci_identity_compartment" "current" {
  id = var.compartment_id
}

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

# Get existing dynamic group if specified
data "oci_identity_dynamic_group" "existing_dynamic_group" {
  count = var.existing_dynamic_group_id != "" ? 1 : 0
  dynamic_group_id = var.existing_dynamic_group_id
}

# Get target stream information
data "oci_streaming_stream" "target_stream" {
  stream_id = var.target_stream_id
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
