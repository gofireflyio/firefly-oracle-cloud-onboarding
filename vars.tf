variable "firefly_endpoint" {
  type    = string
  default = "https://api-env2.dev.firefly.ai/api"
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
  description = "OCID of the compartment to create or use for Firefly resources. If null, a compartment named 'Firefly' will be created in the tenancy."
  default     = null
}


variable "user_ocid" {
  type        = string
  description = "OCI User OCID (optional)"
  default     = ""
}

variable "region" {
  type    = string
  default = "il-jerusalem-1"
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


variable "existing_log_group_id" {
  type    = string
  default = ""
}

variable "existing_dynamic_group_id" {
  type    = string
  default = ""
}

variable "dynamic_group_name" {
  type        = string
  description = "The name of the dynamic group for giving access to service connector"
  default     = "firefly-dynamic-group"
}

variable "firefly_auth_policy" {
  type        = string
  description = "The name of the policy for auth"
  default     = "firefly-auth-policy"
}

variable "existing_user_id" {
  type        = string
  description = "The OCID of an existing user to use. If provided, user_name will be ignored."
  default     = null
}

variable "existing_group_id" {
  type        = string
  description = "The OCID of an existing group to use. If provided, a new group will not be created."
  default     = null
}

variable "create_service_connector" {
  type        = bool
  description = "Whether to create a service connector"
  default     = false
}