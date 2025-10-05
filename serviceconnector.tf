# Create Service Connector Hub
module "service_connector" {
  count = var.create_service_connector ? 1 : 0
  # depends_on        = [null_resource.firefly_validation, module.audit_logging]
  source            = "./modules/service_connector"
  compartment_id    = local.compartment_id
  target_stream_id  = local.stream_id
  tags              = local.common_tags
}

