# Firefly OCI Integration with ORM Stack Support
# This module creates the necessary OCI resources for Firefly integration

# Validate required variables and configurations
# resource "null_resource" "firefly_validation" {
#   provisioner "local-exec" {
#     when       = create
#     on_failure = fail
#     command = <<-EOT
#       # Validate required variables
#       if [ -z "${var.firefly_access_key}" ]; then
#         echo "ERROR: firefly_access_key is required"
#         exit 1
#       fi
      
#       if [ -z "${var.firefly_secret_key}" ]; then
#         echo "ERROR: firefly_secret_key is required"
#         exit 1
#       fi
      
#       if [ -z "${var.target_stream_id}" ]; then
#         echo "ERROR: target_stream_id is required"
#         exit 1
#       fi
      
#       echo "✅ Firefly validation passed"
#     EOT
#   }

#   triggers = {
#     firefly_access_key = var.firefly_access_key
#     firefly_secret_key = var.firefly_secret_key
#     target_stream_id = var.target_stream_id
#   }
# }

# Create compartment for Firefly resources if not using existing
module "compartment" {
  depends_on            = [null_resource.firefly_validation]
  source                = "./modules/compartment"
  compartment_id        = var.compartment_id
  new_compartment_name  = local.new_compartment_name
  parent_compartment_id = var.tenancy_ocid
  tags                  = local.common_tags
}

# # Create KMS vault and key for storing Firefly credentials
# module "kms" {
#   depends_on      = [null_resource.firefly_validation]
#   source          = "./modules/kms"
#   count           = local.is_current_region_home_region ? 1 : 0
#   compartment_id  = module.compartment.id
#   firefly_access_key = var.firefly_access_key
#   firefly_secret_key = var.firefly_secret_key
#   tags            = local.common_tags
# }

# Create IAM resources (Dynamic Group and Policies)
module "auth" {
  depends_on        = [null_resource.firefly_validation]
  source            = "./modules/auth"
  count             = local.is_current_region_home_region ? 1 : 0
  tenancy_id        = var.tenancy_ocid
  compartment_id    = module.compartment.id
  tags              = local.common_tags
  existing_dynamic_group_id = var.existing_dynamic_group_id
  existing_log_group_id = var.existing_log_group_id
  target_stream_id = var.target_stream_id
}

# Create audit logging configuration
module "audit_logging" {
  depends_on        = [null_resource.firefly_validation]
  source            = "./modules/audit_logging"
  count             = local.is_current_region_home_region ? 1 : 0
  compartment_id    = module.compartment.id
  tenancy_ocid      = var.tenancy_ocid
  tags              = local.common_tags
  existing_log_group_id = var.existing_log_group_id
}

# Create Service Connector Hub
module "service_connector" {
  depends_on        = [null_resource.firefly_validation, module.audit_logging]
  source            = "./modules/service_connector"
  count             = local.is_current_region_home_region ? 1 : 0
  compartment_id    = module.compartment.id
  target_stream_id  = var.target_stream_id
  log_group_id      = module.audit_logging[0].log_group_id
  tags              = local.common_tags
}

# Create regional stacks for multi-region deployment
module "regional_stacks" {
  depends_on = [null_resource.firefly_validation, module.compartment, module.auth, module.kms]
  source     = "./modules/regional_stacks"
  count      = local.is_current_region_home_region ? 1 : 0
  
  tenancy_ocid = var.tenancy_ocid
  compartment_id = module.compartment.id
  home_region = local.home_region_name
  target_regions = local.target_regions_for_stacks
  firefly_access_key_secret_id = module.kms[0].firefly_access_key_secret_id
  firefly_secret_key_secret_id = module.kms[0].firefly_secret_key_secret_id
  dynamic_group_id = module.auth[0].dynamic_group_id
  log_group_id = module.audit_logging[0].log_group_id
  target_stream_id = var.target_stream_id
  region = var.region
  tags = local.common_tags
}

# # Firefly integration setup
# module "firefly_integration" {
#   depends_on = [null_resource.firefly_validation, module.auth, module.kms, module.regional_stacks]
#   source     = "./modules/firefly_integration"
#   count      = local.is_current_region_home_region ? 1 : 0
  
#   firefly_endpoint = var.firefly_endpoint
#   firefly_access_key = var.firefly_access_key
#   firefly_secret_key = var.firefly_secret_key
#   tenancy_ocid = var.tenancy_ocid
#   compartment_id = module.compartment.id
#   region = var.region
#   tags = local.common_tags
# }
