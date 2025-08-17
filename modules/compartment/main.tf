terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 5.0"
    }
  }
}

# Check if existing compartment exists
data "oci_identity_compartment" "existing" {
  count = var.compartment_id != "" ? 1 : 0
  id    = var.compartment_id
}

# Create new compartment if not using existing
resource "oci_identity_compartment" "new" {
  count          = var.compartment_id == "" ? 1 : 0
  compartment_id = var.parent_compartment_id
  description    = "Compartment for Firefly OCI integration resources"
  name           = var.new_compartment_name
  freeform_tags  = var.tags
}
