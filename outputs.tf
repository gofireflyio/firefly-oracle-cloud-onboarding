output "dynamic_group_id" {
  description = "The OCID of the Firefly dynamic group"
  value       = local.dynamic_group_id
}

output "log_group_id" {
  description = "The OCID of the Firefly audit log group"
  value       = local.log_group_id
}

output "service_connector_id" {
  description = "The OCID of the Firefly service connector"
  value       = module.service_connector[0].service_connector_id
}

output "audit_configuration_id" {
  description = "The OCID of the audit configuration"
  value       = module.audit_logging[0].audit_configuration_id
}

output "firefly_access_key_secret_id" {
  description = "The OCID of the Firefly access key secret"
  value       = module.kms[0].firefly_access_key_secret_id
}

output "firefly_secret_key_secret_id" {
  description = "The OCID of the Firefly secret key secret"
  value       = module.kms[0].firefly_secret_key_secret_id
}

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
    compartment_id   = module.compartment.id
    compartment_name = module.compartment.name
  }
}

output "region_info" {
  description = "Information about the OCI region"
  value = {
    region           = var.region
    is_home_region   = local.is_current_region_home_region
    subscribed_regions = local.target_regions_for_stacks
  }
}

output "target_stream_info" {
  description = "Information about the target stream"
  value = {
    stream_id = var.target_stream_id
    stream_name = data.oci_streaming_stream.target_stream.name
  }
}

output "regional_stacks_info" {
  description = "Information about regional ORM stacks"
  value = module.regional_stacks[0].regional_stacks
}

output "stack_digest" {
  description = "Unique identifier for the regional stack deployment"
  value = module.regional_stacks[0].stack_digest
}

output "firefly_integration_config" {
  description = "Firefly integration configuration"
  value = module.firefly_integration[0].integration_config
  sensitive = true
}
