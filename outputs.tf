output "firefly_compartment_id" {
  description = "The OCID of the Firefly compartment (auto-created or user-provided)"
  value       = local.firefly_compartment_id
}

output "firefly_compartment_created" {
  description = "Whether a new Firefly compartment was created"
  value       = length(oci_identity_compartment.firefly) > 0
}

output "dynamic_group_id" {
  description = "The OCID of the Firefly dynamic group"
  value       = local.dynamic_group_id
}


output "service_connectors_by_region" {
  description = "Service Connectors created per region"
  value = {
    for region, module_data in module.service_connector_by_region :
    region => {
      id           = module_data.service_connector_id
      display_name = module_data.display_name
      region       = region
    }
  }
}


output "tenancy_info" {
  description = "Information about the OCI tenancy"
  value = {
    tenancy_ocid = data.oci_identity_tenancy.current.id
    tenancy_name = data.oci_identity_tenancy.current.name
    # home_region  = local.home_region_name
  }
}

output "compartment_info" {
  description = "Information about the OCI compartment"
  value = {
    compartment_id   = local.compartment_id
  }
}


output "firefly_integration_config" {
  description = "Firefly integration configuration"
  value = module.firefly_oci_integration.user_ocid
  sensitive = false
}


output "public_key" {
  value = module.firefly_oci_integration.public_key
}

output "fingerprint" {
  value = module.firefly_oci_integration.fingerprint
}

output "integration_id" {
  value = module.firefly_oci_integration.integration_id
}

output "response_message" {
  value = module.firefly_oci_integration.response_body
}