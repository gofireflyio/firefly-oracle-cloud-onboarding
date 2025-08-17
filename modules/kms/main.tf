terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 5.0"
    }
  }
}

# Create KMS Vault for storing Firefly credentials
resource "oci_kms_vault" "firefly_vault" {
  compartment_id = var.compartment_id
  display_name   = "firefly-credentials-vault"
  vault_type     = "DEFAULT"
  freeform_tags  = var.tags
}

# Create KMS Key for encrypting secrets
resource "oci_kms_key" "firefly_key" {
  compartment_id = var.compartment_id
  display_name   = "firefly-secrets-key"
  key_shape {
    algorithm = "AES"
    length    = 32
  }
  management_endpoint = oci_kms_vault.firefly_vault.management_endpoint
  freeform_tags       = var.tags
}

# Store Firefly access key as secret
resource "oci_vault_secret" "firefly_access_key" {
  compartment_id = var.compartment_id
  vault_id       = oci_kms_vault.firefly_vault.id
  key_id         = oci_kms_key.firefly_key.id
  description    = "Firefly access key for OCI integration"
  secret_name    = "firefly-access-key"
  secret_content {
    content_type = "BASE64"
    content      = base64encode(var.firefly_access_key)
  }
  freeform_tags  = var.tags
}

# Store Firefly secret key as secret
resource "oci_vault_secret" "firefly_secret_key" {
  compartment_id = var.compartment_id
  vault_id       = oci_kms_vault.firefly_vault.id
  key_id         = oci_kms_key.firefly_key.id
  description    = "Firefly secret key for OCI integration"
  secret_name    = "firefly-secret-key"
  secret_content {
    content_type = "BASE64"
    content      = base64encode(var.firefly_secret_key)
  }
  freeform_tags  = var.tags
}
