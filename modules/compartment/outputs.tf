output "id" {
  description = "The OCID of the compartment (either existing or newly created)"
  value       = var.compartment_id != "" ? var.compartment_id : oci_identity_compartment.new[0].id
}

output "name" {
  description = "The name of the compartment"
  value       = var.compartment_id != "" ? data.oci_identity_compartment.existing[0].name : oci_identity_compartment.new[0].name
}
