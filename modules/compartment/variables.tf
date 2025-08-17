variable "compartment_id" {
  description = "Existing compartment OCID to use. If empty, a new compartment will be created."
  type        = string
  default     = ""
}

variable "parent_compartment_id" {
  description = "Parent compartment OCID where the new compartment will be created"
  type        = string
}

variable "new_compartment_name" {
  description = "Name for the new compartment if creating one"
  type        = string
}

variable "tags" {
  description = "Tags to apply to the compartment"
  type        = map(string)
  default     = {}
}
