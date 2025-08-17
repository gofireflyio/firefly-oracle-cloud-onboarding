variable "tenancy_id" {
  description = "OCI Tenancy OCID"
  type        = string
}

variable "compartment_id" {
  description = "Compartment OCID where policies will be created"
  type        = string
}

variable "existing_dynamic_group_id" {
  description = "Existing dynamic group OCID to use. If empty, a new one will be created."
  type        = string
  default     = ""
}

variable "existing_log_group_id" {
  description = "Existing log group OCID to use. If empty, a new one will be created."
  type        = string
  default     = ""
}

variable "target_stream_id" {
  description = "Target stream OCID for Service Connector Hub"
  type        = string
}

variable "tags" {
  description = "Tags to apply to IAM resources"
  type        = map(string)
  default     = {}
}
