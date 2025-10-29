terraform {
  required_version = ">= 1.5.0"
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">=7.1.0"
    }
  }
}

# Event filter conditions for OCI audit events (v2.0.3 policy)
locals {
  # Comprehensive list of OCI events to filter for Firefly monitoring
  event_filters = [
    # Object Storage events
    "com.oraclecloud.objectstorage.createbucket",
    "com.oraclecloud.objectstorage.updatebucket",
    "com.oraclecloud.objectstorage.deletebucket",

    # Identity Control Plane - User events
    "com.oraclecloud.identityControlPlane.CreateUser",
    "com.oraclecloud.identityControlPlane.UpdateUser",
    "com.oraclecloud.identityControlPlane.DeleteUser",

    # Identity Control Plane - Compartment events
    "com.oraclecloud.identityControlPlane.CreateCompartment",
    "com.oraclecloud.identityControlPlane.UpdateCompartment",
    "com.oraclecloud.identityControlPlane.DeleteCompartment",

    # Identity Control Plane - Group events
    "com.oraclecloud.identityControlPlane.CreateGroup",
    "com.oraclecloud.identityControlPlane.UpdateGroup",
    "com.oraclecloud.identityControlPlane.DeleteGroup",
    "com.oraclecloud.identityControlPlane.AddUserToGroup",
    "com.oraclecloud.identityControlPlane.RemoveUserFromGroup",

    # Identity Control Plane - Policy events
    "com.oraclecloud.identityControlPlane.CreatePolicy",
    "com.oraclecloud.identityControlPlane.UpdatePolicy",
    "com.oraclecloud.identityControlPlane.DeletePolicy",

    # Identity Control Plane - Dynamic Group events
    "com.oraclecloud.identityControlPlane.CreateDynamicGroup",
    "com.oraclecloud.identityControlPlane.UpdateDynamicGroup",
    "com.oraclecloud.identityControlPlane.DeleteDynamicGroup",

    # Compute API - Instance launch events
    "com.oraclecloud.computeapi.launchinstance.begin",
    "com.oraclecloud.computeapi.launchinstance.end",
    "com.oraclecloud.computeapi.updateinstance",

    # Compute API - Instance termination events
    "com.oraclecloud.computeapi.terminateinstance.begin",
    "com.oraclecloud.computeapi.terminateinstance.end",

    # Block Volumes - Create events
    "com.oraclecloud.blockvolumes.createvolume.begin",
    "com.oraclecloud.blockvolumes.createvolume.end",

    # Block Volumes - Update and Delete events
    "com.oraclecloud.blockvolumes.updatevolume",
    "com.oraclecloud.blockvolumes.deletevolume.begin",
    "com.oraclecloud.blockvolumes.deletevolume.end",

    # Virtual Network - VCN events
    "com.oraclecloud.virtualnetwork.createvcn",
    "com.oraclecloud.virtualnetwork.updatevcn",
    "com.oraclecloud.virtualnetwork.deletevcn",

    # Virtual Network - Subnet events
    "com.oraclecloud.virtualnetwork.createsubnet",
    "com.oraclecloud.virtualnetwork.updatesubnet",
    "com.oraclecloud.virtualnetwork.deletesubnet",

    # Virtual Network - Internet Gateway events
    "com.oraclecloud.virtualnetwork.createinternetgateway",
    "com.oraclecloud.virtualnetwork.updateinternetgateway",
    "com.oraclecloud.virtualnetwork.deleteinternetgateway",

    # Virtual Network - Route Table events
    "com.oraclecloud.virtualnetwork.createroutetable",
    "com.oraclecloud.virtualnetwork.updateroutetable",
    "com.oraclecloud.virtualnetwork.deleteroutetable",

    # Virtual Network - Security List events
    "com.oraclecloud.virtualnetwork.createsecuritylist",
    "com.oraclecloud.virtualnetwork.updatesecuritylist",
    "com.oraclecloud.virtualnetwork.deletesecuritylist",

    # Compute API - Volume attachment events
    "com.oraclecloud.computeapi.attachvolume.begin",
    "com.oraclecloud.computeapi.attachvolume.end",
    "com.oraclecloud.computeapi.updatevolumeattachment",
    "com.oraclecloud.computeapi.detachvolume.begin",
    "com.oraclecloud.computeapi.detachvolume.end",
  ]

  # Build filter conditions: (type='event1' or type='event2' or ...)
  # This creates the OCI SCH filter expression for event-based routing
  filter_condition = "(${join(" or ", [for event in local.event_filters : "type='${event}'"])})"
}

# Create Service Connector Hub to route audit logs
resource "oci_sch_service_connector" "firefly_connector" {
  compartment_id = var.compartment_id
  display_name   = var.display_name
  description    = "Service Connector Hub for routing Firefly audit logs to stream in region ${var.region}"

  # Source: Audit Log Group with event filtering
  source {
    kind = "logging"
    log_sources {
      compartment_id = var.tenancy_ocid
      log_group_id   = "_Audit_Include_Subcompartment"
    }
  }

  # Task: Filter events based on Firefly policy
  tasks {
    kind      = "logRule"
    condition = local.filter_condition
  }

  # Target: OCI Stream (configurable via variable)
  dynamic "target" {
    for_each = var.target_stream_id != "" ? [1] : []
    content {
      kind      = "streaming"
      stream_id = var.target_stream_id
    }
  }

  freeform_tags = var.tags

  lifecycle {
    ignore_changes = [defined_tags]
  }
}
