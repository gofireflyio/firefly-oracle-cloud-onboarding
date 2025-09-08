variable "firefly_endpoint" {
  type        = string
  description = "The Firefly endpoint to register account management"
  # default     = "https://prodapi.gofirefly.io/api"
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

variable "tenancy_name" {
  type        = string
  description = "OCI Tenancy name"
}

variable "user_ocid" {
  type        = string
  description = "OCI User OCID"
  default     = null
}

variable "public_key" {
  type        = string
  description = "OCI API key public key content"
  default     = null
}

variable "fingerprint" {
  type        = string
  description = "OCI API key fingerprint"
  default     = null
}

variable "is_prod" {
  type        = bool
  description = "Whether this is a production environment"
  default     = true
}

variable "eventdriven_enabled" {
  type        = bool
  description = "Whether event-driven integration is enabled"
  default     = true
}

variable "iac_auto_discovery_disabled" {
  type        = bool
  description = "Whether IaC auto discovery is disabled"
  default     = true
}

variable "auto_discover_enabled" {
  type        = bool
  description = "Whether auto discovery is enabled"
  default     = true
}