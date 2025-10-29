# Create Firefly compartment if not provided by user
# This compartment is created in the root tenancy and will be used for all Firefly resources
resource "oci_identity_compartment" "firefly" {
  count          = var.compartment_ocid == null ? 1 : 0
  compartment_id = var.tenancy_ocid
  name           = "Firefly"
  description    = "Firefly OCI Integration - Managed by Terraform"

  freeform_tags = {
    "ManagedBy" = "Terraform"
    "Purpose"   = "Firefly-OCI-Integration"
    "Version"   = "1.0.0"
  }
}


