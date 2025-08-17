variable "firefly_endpoint" {
  type    = string
  default = "https://prodapi.firefly.ai/api"
}

variable "firefly_webhook_url" {
  type    = string
  default = "https://oci-events.firefly.ai"
}

variable "trigger_integrations" {
  type    = bool
  default = true
}

variable "firefly_access_key" {
  type        = string
  description = "Your authentication access_key"
  validation {
    condition     = var.firefly_access_key != ""
    error_message = "Variable \"firefly_access_key\" cannot be empty."
  }
}

variable "firefly_secret_key" {
  type        = string
  description = "Your authentication secret_key"
  validation {
    condition     = var.firefly_secret_key != ""
    error_message = "Variable \"firefly_secret_key\" cannot be empty."
  }
}

variable "tenancy_ocid" {
  type        = string
  description = "OCI Tenancy OCID"
  validation {
    condition     = var.tenancy_ocid != ""
    error_message = "Variable \"tenancy_ocid\" cannot be empty."
  }
}

variable "compartment_id" {
  type        = string
  description = "OCI Compartment OCID"
  validation {
    condition     = var.compartment_id != ""
    error_message = "Variable \"compartment_id\" cannot be empty."
  }
}

variable "user_ocid" {
  type        = string
  description = "OCI User OCID (optional)"
  default     = ""
}

variable "region" {
  type    = string
  default = "us-ashburn-1"
}

variable "prefix" {
  type    = string
  default = ""
}

variable "suffix" {
  type    = string
  default = ""
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "target_stream_id" {
  type        = string
  description = "OCI Stream OCID for Service Connector Hub target"
  validation {
    condition     = var.target_stream_id != ""
    error_message = "Variable \"target_stream_id\" cannot be empty."
  }
}

variable "existing_log_group_id" {
  type    = string
  default = ""
}

variable "existing_dynamic_group_id" {
  type    = string
  default = ""
}

variable "firefly_eips" {
  type = list(string)
  default = [
    "3.224.145.192",
    "54.83.245.177",
    "3.213.167.195",
    "54.146.252.237",
    "34.226.97.113"
  ]
}
