#Auth Variables
locals {
  user_name              = "${local.name_prefix}firefly-svc${local.name_suffix}"
  user_group_name        = "${local.user_name}-group"
  user_group_policy_name = "${local.user_name}-policy"
  firefly_sch_name            = "${local.name_prefix}firefly-dynamic-group-connectorhubs${local.name_suffix}"
  firefly_policy_name         = "${local.name_prefix}firefly-dynamic-group-policy${local.name_suffix}"
  dynamic_group_name           = "${local.name_prefix}${var.dynamic_group_name}${local.name_suffix}"
  matching_domain_id = (
    # If the domain is specified, use that
    var.domain_id != null && var.domain_id != "" ?
    var.domain_id :
    (
      # If a user and group are specified, find the associated domain
      var.existing_user_id != null && var.existing_user_id != "" ?
      (
        length([for k, v in data.oci_identity_domains_user.existing_user_in_domain : k if v.active != null]) > 0 ?
        [for k, v in data.oci_identity_domains_user.existing_user_in_domain : k if v.active != null][0] :
        null
      ) :
      # If no user or group is specified, find the domain associated with the current user
      (
        length([for k, v in data.oci_identity_domains_user.user_in_domain : k if v.active != null]) > 0 ?
        [for k, v in data.oci_identity_domains_user.user_in_domain : k if v.active != null][0] :
        null
      )
    )
  )

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
  policy_name    = "${local.name_prefix}firefly-policy${local.name_suffix}"
  connector_name = "${local.name_prefix}firefly-connector${local.name_suffix}"

  # Compartment selection logic
  # Priority: var.compartment_ocid (user-provided) > oci_identity_compartment.firefly (auto-created)
  firefly_compartment_id = (
    var.compartment_ocid != null ? var.compartment_ocid :
    oci_identity_compartment.firefly[0].id
  )

  # Tenancy and compartment info
  tenancy_name   = data.oci_identity_tenancy.current.name
  compartment_id = local.firefly_compartment_id

  # Domain selection - use domain_id if provided, otherwise use the first matching domain
  effective_domain_id = var.domain_id != "" ? var.domain_id : local.matching_domain_id

  # Common tags
  common_tags = merge(var.tags, {
    "ManagedBy" = "Terraform"
    "Purpose"   = "Firefly-OCI-Integration"
    "Version"   = "1.0.0"
    "Tenancy"   = data.oci_identity_tenancy.current.name
    "Region"    = var.region
  })

  # Resource IDs - these will be available after the modules are created
  dynamic_group_id = var.existing_dynamic_group_id != "" ? var.existing_dynamic_group_id : null

  # Availability domains
  availability_domains = data.oci_identity_availability_domains.ads.availability_domains
  tenancy_home_region  = data.oci_identity_tenancy.current.home_region_key

  # Firefly stream configuration
  firefly_stream_ids = try(jsondecode(data.http.firefly_stream_lookup[0].response_body), {})
  # Lookup actual stream ID from Firefly's service
  stream_id = lookup(local.firefly_stream_ids, var.region, "unknown")
}

locals {
  policy_statements = var.managed_service_connector ? [
    "Define tenancy Firefly as ocid1.tenancy.oc1..aaaaaaaahxrxe37ndpd3xidrt4laffdtxhdaq4srccux3cumrugervil4inq",
    "Allow group id ${var.existing_group_id != null && var.existing_group_id != "" ? var.existing_group_id : oci_identity_domains_group.firefly_auth[0].ocid} to read all-resources in tenancy",
    "Allow group id ${var.existing_group_id != null && var.existing_group_id != "" ? var.existing_group_id : oci_identity_domains_group.firefly_auth[0].ocid} to manage serviceconnectors in compartment id ${local.firefly_compartment_id}",
    "Allow dynamic-group id ${oci_identity_domains_dynamic_resource_group.firefly_serviceconnector_group[0].ocid} to read audit-events in tenancy",
    "Allow dynamic-group id ${oci_identity_domains_dynamic_resource_group.firefly_serviceconnector_group[0].ocid} to read logging-family in tenancy",
    "Endorse dynamic-group id ${oci_identity_domains_dynamic_resource_group.firefly_serviceconnector_group[0].ocid} to {STREAM_READ, STREAM_PRODUCE} in tenancy Firefly"
  ] : [
    "Define tenancy Firefly as ocid1.tenancy.oc1..aaaaaaaahxrxe37ndpd3xidrt4laffdtxhdaq4srccux3cumrugervil4inq",
    "Allow group id ${var.existing_group_id != null && var.existing_group_id != "" ? var.existing_group_id : oci_identity_domains_group.firefly_auth[0].ocid} to read all-resources in tenancy",
    "Allow group id ${var.existing_group_id != null && var.existing_group_id != "" ? var.existing_group_id : oci_identity_domains_group.firefly_auth[0].ocid} to read dynamic-groups in tenancy",
    "Allow dynamic-group id ${oci_identity_domains_dynamic_resource_group.firefly_serviceconnector_group[0].ocid} to read audit-events in tenancy",
    "Allow dynamic-group id ${oci_identity_domains_dynamic_resource_group.firefly_serviceconnector_group[0].ocid} to read logging-family in tenancy",
    "Endorse dynamic-group id ${oci_identity_domains_dynamic_resource_group.firefly_serviceconnector_group[0].ocid} to {STREAM_READ, STREAM_PRODUCE} in tenancy Firefly"
  ]

  # Regional Stacks Configuration
  # Get subscribed regions
  subscribed_regions = [for r in data.oci_identity_region_subscriptions.all_regions.region_subscriptions : r.region_name]

  # Determine target regions: use event_driven_regions if provided, otherwise use subscribed regions
  target_regions = length(var.event_driven_regions) > 0 ? var.event_driven_regions : local.subscribed_regions

  # Convert target_regions to set for for_each
  target_regions_set = toset(local.target_regions)

  # Parse Firefly stream IDs per region from API response
  firefly_stream_ids_map = try(jsondecode(data.http.firefly_stream_lookup[0].response_body), {})
}