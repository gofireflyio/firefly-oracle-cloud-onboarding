variable "compartment_id" {
  description = "Compartment OCID where audit logging resources will be created"
  type        = string
}

variable "tenancy_ocid" {
  description = "OCI Tenancy OCID"
  type        = string
}

variable "existing_log_group_id" {
  description = "Existing log group OCID to use. If empty, a new one will be created."
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to audit logging resources"
  type        = map(string)
  default     = {}
}
