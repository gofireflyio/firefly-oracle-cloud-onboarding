terraform {
  required_version = ">= 1.5.0"
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">=7.16.0"
    }
  }
}

provider "oci" {
  config_file_profile = "firefly-dev"
  region       = var.region
}

provider "oci" {
  alias        = "home"
  config_file_profile = "firefly-dev"
  region       = data.oci_identity_tenancy.current.home_region_key
}

