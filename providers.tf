terraform {
  required_version = ">= 1.5.0"
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">=7.16.0"
    }
  }
}

# provider oci { 
#     alias = "home"
#     region = var.region
#     # region = lookup(local.region_map, data.oci_identity_tenancy.tenancy.home_region_key)
# }

variable "region" {
}

provider "oci" {
  tenancy_ocid = var.tenancy_ocid
  region = "${var.region}"
}

provider "oci" {
  alias        = "home"
  tenancy_ocid = var.tenancy_ocid
  region       = local.region
}

data oci_identity_regions regions {
}

data oci_identity_tenancy tenancy {
    tenancy_id = var.tenancy_ocid
}

locals {
    tenancy_home_region = data.oci_identity_tenancy.tenancy.home_region_key
    region_map = { for r in data.oci_identity_regions.regions.regions : r.key => r.name }
    home_region_name = local.tenancy_home_region
}