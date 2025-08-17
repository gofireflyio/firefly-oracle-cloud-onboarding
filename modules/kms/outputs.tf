output "firefly_access_key_secret_id" {
  description = "The OCID of the Firefly access key secret"
  value       = oci_vault_secret.firefly_access_key.id
}

output "firefly_secret_key_secret_id" {
  description = "The OCID of the Firefly secret key secret"
  value       = oci_vault_secret.firefly_secret_key.id
}

output "vault_id" {
  description = "The OCID of the KMS vault"
  value       = oci_kms_vault.firefly_vault.id
}

output "key_id" {
  description = "The OCID of the KMS key"
  value       = oci_kms_key.firefly_key.id
}
