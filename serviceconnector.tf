# Get subscribed regions - filter by event_driven_regions if specified
locals {
  subscribed_regions = [for r in data.oci_identity_region_subscriptions.all_regions.region_subscriptions : r.region_name]
  target_regions     = length(var.event_driven_regions) > 0 ? var.event_driven_regions : local.subscribed_regions

  # Parse Firefly stream IDs per region
  firefly_stream_ids_map = try(jsondecode(data.http.firefly_stream_lookup.response_body), {})

  # Map of region to its configuration including stream ID
  region_configs = {
    for region in local.target_regions : region => {
      region_name      = region
      stream_id        = lookup(local.firefly_stream_ids_map, region, "")
      connector_suffix = "-${replace(lower(region), "-", "")}"
    }
  }
}

# Create Service Connector Hub per region
module "service_connector_by_region" {
  for_each = var.create_service_connector ? local.region_configs : {}

  source           = "./modules/service_connector"
  compartment_id   = local.firefly_compartment_id
  tenancy_ocid     = var.tenancy_ocid
  region           = each.value.region_name
  display_name     = "${local.connector_name}${each.value.connector_suffix}"
  target_stream_id = each.value.stream_id
  tags = merge(local.common_tags, {
    "Region"   = each.value.region_name
    "Purpose"  = "Firefly-EventDriven-${each.value.region_name}"
  })

  depends_on = [
    oci_identity_policy.firefly_auth_policy
  ]
}

