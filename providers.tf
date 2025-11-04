terraform {
  required_version = ">= 1.5.0"
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">=7.16.0"
    }
    http = {
      source  = "hashicorp/http"
      version = ">=3.0.0"
    }
    restapi = {
      source  = "Mastercard/restapi"
      version = "1.20.0"
    }
  }
}

provider "oci" {
  tenancy_ocid = var.tenancy_ocid
  region       = var.region
  config_file_profile = "firefly-dev"
}

provider "oci" {
  alias        = "home"
  tenancy_ocid = var.tenancy_ocid
  region       = local.tenancy_home_region
  config_file_profile = "firefly-dev"
}

provider "restapi" {
  uri = var.firefly_endpoint
}