output "dynamic_group_id" {
  description = "The OCID of the Firefly dynamic group"
  value       = local.dynamic_group_id
}


# output "service_connector_id" {
#   description = "The OCID of the Firefly service connector"
#   value       = module.service_connector[0].service_connector_id
# }


output "tenancy_info" {
  description = "Information about the OCI tenancy"
  value = {
    tenancy_ocid = data.oci_identity_tenancy.current.id
    tenancy_name = data.oci_identity_tenancy.current.name
    home_region  = local.home_region_name
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