variable "firefly_endpoint" {
  type        = string
  description = "The Firefly endpoint to register account management"
  default     = "https://prodapi.gofirefly.io/api"
}

variable "firefly_token" {
  type        = string
  description = "Firefly authentication token"
  sensitive   = true
}

variable "tenancy_ocid" {
  type        = string
  description = "OCI Tenancy OCID"
}

variable "compartment_id" {
  type        = string
  description = "OCI Compartment OCID"
}

variable "region" {
  type        = string
  description = "OCI region"
}

variable "prefix" {
  type        = string
  description = "Resource naming prefix"
  default     = ""
}

variable "suffix" {
  type        = string
  description = "Resource naming suffix"
  default     = ""
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to resources"
  default     = {}
}
