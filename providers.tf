terraform {
  required_version = ">= 1.5.0"
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">=7.16.0"
    }
  }
}

provider oci {}

provider oci { 
    alias = "home" 
    region = lookup(local.region_map, data.oci_identity_tenancy.tenancy.home_region_key)
}

data oci_identity_regions regions {}

data oci_identity_tenancy tenancy {
    tenancy_id = var.tenancy_ocid
}

locals {
    region_map = { for r in data.oci_identity_regions.regions.regions : r.key => r.name }
    home_region_name = lookup(local.region_map, data.oci_identity_tenancy.tenancy.home_region_key)
}

output home_region {
    value = lookup(local.region_map, data.oci_identity_tenancy.tenancy.home_region_key)
} 