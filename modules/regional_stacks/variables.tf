variable "tenancy_ocid" {
  description = "OCI Tenancy OCID"
  type        = string
}

variable "compartment_id" {
  description = "Compartment OCID where regional stacks will be created"
  type        = string
}

variable "home_region" {
  description = "Home region name"
  type        = string
}

variable "target_regions" {
  description = "Map of target regions where regional stacks will be created"
  type        = map(object({
    region_key = string
    region_name = string
    is_home_region = bool
  }))
}

variable "firefly_access_key_secret_id" {
  description = "Secret OCID for Firefly access key"
  type        = string
}

variable "firefly_secret_key_secret_id" {
  description = "Secret OCID for Firefly secret key"
  type        = string
}

variable "dynamic_group_id" {
  description = "Dynamic group OCID for Firefly"
  type        = string
}

variable "log_group_id" {
  description = "Log group OCID for audit logs"
  type        = string
}

variable "target_stream_id" {
  description = "Target stream OCID for Service Connector Hub"
  type        = string
}

variable "tags" {
  description = "Tags to apply to regional stack resources"
  type        = map(string)
  default     = {}
}

# Variables for the regional stack configuration
variable "region" {
  description = "The specific region where this regional stack is deployed"
  type        = string
}
