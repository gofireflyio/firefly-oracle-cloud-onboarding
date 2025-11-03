variable "region" {
  type        = string
  description = "OCI Region for default provider"
}

variable "firefly_endpoint" {
  type    = string
  default = "https://prodapi.firefly.ai/api"
}

variable "firefly_access_key" {
  sensitive   = true
  type        = string
  description = "Your authentication access_key"
  validation {
    condition     = var.firefly_access_key != ""
    error_message = "Variable \"firefly_access_key\" cannot be empty."
  }
}

variable "firefly_secret_key" {
  sensitive   = true
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

variable "compartment_ocid" {
  type        = string
  description = "OCID of the compartment to use for Firefly resources. If null, a compartment named 'Firefly' will be created in the tenancy."
  default     = null
}

variable "domain_id" {
  type        = string
  description = "OCID of the identity domain to use for user and group management. If not provided, the default domain will be used."
  default     = ""
}


variable "current_user_ocid" {
  type        = string
  description = "OCI User OCID (optional)"
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

variable "managed_service_connector" {
  type        = bool
  description = "Whether to let Firefly manage the service connector"
  default     = false
}

variable "event_driven_regions" {
  type        = list(string)
  description = "OCI regions for event-driven integration"
  default     = []
}


variable "is_prod" {
  type        = bool
  description = "Whether this is a production environment"
  default     = true
}

variable "integrationSessionId" {
  type        = string
  description = "Integration session ID"
  default     = null
}

variable "skip_integration_request" {
  type        = bool
  description = "Skip the HTTP integration request (useful for destroy operations)"
  default     = false
}