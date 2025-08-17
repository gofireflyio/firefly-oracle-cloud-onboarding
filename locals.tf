locals {
  # Common naming
  name_prefix = var.prefix != "" ? "${var.prefix}-" : ""
  name_suffix = var.suffix != "" ? "-${var.suffix}" : ""
  
  # Resource names
  dynamic_group_name = "${local.name_prefix}firefly-dynamic-group${local.name_suffix}"
  log_group_name     = "${local.name_prefix}firefly-audit-logs${local.name_suffix}"
  policy_name        = "${local.name_prefix}firefly-policy${local.name_suffix}"
  connector_name     = "${local.name_prefix}firefly-connector${local.name_suffix}"
  
  # Common tags
  common_tags = merge(var.tags, {
    "ManagedBy" = "Terraform"
    "Purpose"   = "Firefly-OCI-Integration"
    "Version"   = "1.0.0"
    "Tenancy"   = data.oci_identity_tenancy.current.name
    "Compartment" = data.oci_identity_compartment.current.name
    "Region"    = var.region
  })
  
  # Resource IDs
  log_group_id = var.existing_log_group_id != "" ? var.existing_log_group_id : oci_logging_log_group.firefly_audit_logs[0].id
  dynamic_group_id = var.existing_dynamic_group_id != "" ? var.existing_dynamic_group_id : oci_identity_dynamic_group.firefly_dynamic_group[0].id
  
  # Tenancy and compartment info
  tenancy_name = data.oci_identity_tenancy.current.name
  compartment_name = data.oci_identity_compartment.current.name
  
  # Availability domains
  availability_domains = data.oci_identity_availability_domains.ads.availability_domains
  
  # Region and compartment configuration for ORM stacks
  is_current_region_home_region = var.region == local.home_region_name
  home_region_name = data.oci_identity_region_subscriptions.current.region_subscriptions[0].region_name
  
  # Target regions for regional stacks (all subscribed regions)
  target_regions_for_stacks = {
    for region in data.oci_identity_region_subscriptions.current.region_subscriptions : 
    region.region_name => {
      region_key = region.region_key
      region_name = region.region_name
      is_home_region = region.is_home_region
    }
  }
  
  # New compartment name for Firefly resources
  new_compartment_name = "${local.name_prefix}firefly-integration${local.name_suffix}"
}
