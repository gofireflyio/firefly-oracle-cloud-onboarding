variable "compartment_id" {
  description = "Compartment OCID where the service connector will be created"
  type        = string
}

variable "target_stream_id" {
  description = "Target stream OCID for the service connector"
  type        = string
}

variable "tags" {
  description = "Tags to apply to the service connector"
  type        = map(string)
  default     = {}
}

