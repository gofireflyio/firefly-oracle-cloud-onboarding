variable "compartment_id" {
  description = "Compartment OCID where the service connector will be created"
  type        = string
}

variable "region" {
  description = "OCI region for the service connector"
  type        = string
  default     = "us-phoenix-1"
}

variable "display_name" {
  description = "Display name for the service connector"
  type        = string
  default     = "firefly-audit-connector"
}

variable "target_stream_id" {
  description = "Target stream OCID for the service connector"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to the service connector"
  type        = map(string)
  default     = {}
}

variable "tenancy_ocid" {
  description = "OCI Tenancy OCID"
  type        = string
}