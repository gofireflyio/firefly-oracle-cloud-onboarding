#Auth Variables
locals {
  user_name              = "firefly-svc"
  user_group_name        = "${local.user_name}-admin"
  user_group_policy_name = "${local.user_name}-policy"
  firefly_sch_name            = "${var.prefix}firefly-dynamic-group-connectorhubs${var.suffix}"
  firefly_policy_name         = "${var.prefix}firefly-dynamic-group-policy${var.suffix}"
  matching_domain_id     = [for k, v in data.oci_identity_domains_user.user_in_domain : k if v.emails != null][0]
  matching_domain = [
    for d in data.oci_identity_domains.all_domains.domains : d
    if d.id == local.matching_domain_id
  ][0]
  user_email = "oci@firefly.ai"

  domain_display_name = local.matching_domain.display_name
  idcs_endpoint       = local.matching_domain.url

  actual_user_name  = (var.existing_user_id == null || var.existing_user_id == "") ? local.user_name : null
  actual_group_name = (var.existing_group_id == null || var.existing_group_id == "") ? local.user_group_name : null
}

locals {
  # Common naming
  name_prefix = var.prefix != "" ? "${var.prefix}-" : ""
  name_suffix = var.suffix != "" ? "-${var.suffix}" : ""
  
  # Resource names
  # dynamic_group_name = "${local.name_prefix}firefly-dynamic-group${local.name_suffix}"
  # log_group_name     = "${local.name_prefix}firefly-audit-logs${local.name_suffix}"
  policy_name        = "${local.name_prefix}firefly-policy${local.name_suffix}"
  connector_name     = "${local.name_prefix}firefly-connector${local.name_suffix}"
  
  # Common tags
  common_tags = merge(var.tags, {
    "ManagedBy" = "Terraform"
    "Purpose"   = "Firefly-OCI-Integration"
    "Version"   = "1.0.0"
    "Tenancy"   = data.oci_identity_tenancy.current.name
    # "Compartment" = data.oci_identity_compartment.current.name
    "Region"    = var.region
  })
  
  # Resource IDs - these will be available after the modules are created
  # We'll reference them through module outputs instead of direct resource references
  log_group_id = var.existing_log_group_id != "" ? var.existing_log_group_id : null
  dynamic_group_id = var.existing_dynamic_group_id != "" ? var.existing_dynamic_group_id : null
  
  # Tenancy and compartment info
  tenancy_name = data.oci_identity_tenancy.current.name
  # compartment_name = data.oci_identity_compartment.current.name
  compartment_id = var.tenancy_ocid
  
  # Availability domains
  availability_domains = data.oci_identity_availability_domains.ads.availability_domains
  region = data.oci_identity_tenancy.current.home_region_key
  
  firefly_stream_ids = try(jsondecode(data.http.firefly_stream_lookup.response_body), {})
  # Lookup actual stream ID from Firefly's service
  stream_id = lookup(local.firefly_stream_ids, var.region, "unknown")
}

