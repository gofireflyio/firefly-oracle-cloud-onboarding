variable "tenancy_ocid" {
  type        = string
  description = "OCI Tenancy OCID"
}

variable "compartment_ocid" {
  type        = string
  description = "OCI Compartment OCID where resources will be created"
}

variable "region" {
  type        = string
  description = "OCI region for this regional stack"
}

variable "home_region" {
  type        = string
  description = "Home region of the tenancy (for home region provider)"
}

variable "display_name" {
  type        = string
  description = "Display name for the service connector"
  default     = "firefly-audit-connector"
}

variable "target_stream_id" {
  type        = string
  description = "Target stream OCID for the service connector"
  default     = ""
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to resources"
  default     = {}
}

variable "firefly_endpoint" {
  type        = string
  description = "The Firefly endpoint"
  default     = "https://prodapi.gofirefly.io/api"
}

variable "firefly_token" {
  type        = string
  description = "Firefly authentication token"
  sensitive   = true
  default     = ""
}
