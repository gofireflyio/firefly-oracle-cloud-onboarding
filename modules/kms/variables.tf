variable "compartment_id" {
  description = "Compartment OCID where KMS resources will be created"
  type        = string
}

variable "firefly_access_key" {
  description = "Firefly access key to store as secret"
  type        = string
  sensitive   = true
}

variable "firefly_secret_key" {
  description = "Firefly secret key to store as secret"
  type        = string
  sensitive   = true
}

variable "tags" {
  description = "Tags to apply to KMS resources"
  type        = map(string)
  default     = {}
}
