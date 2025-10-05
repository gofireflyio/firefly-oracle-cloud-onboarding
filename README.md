# Firefly OCI Integration

![Firefly Logo](firefly.gif)

This Terraform module automates the complete integration of Firefly with Oracle Cloud Infrastructure (OCI). It creates all necessary OCI IAM resources, establishes secure authentication, sets up audit log streaming via Service Connector Hub, and registers your OCI tenancy with Firefly for comprehensive cloud asset management and monitoring.

## Table of Contents

- [Firefly OCI Integration](#firefly-oci-integration)
  - [Table of Contents](#table-of-contents)
  - [Prerequisites](#prerequisites)
  - [Required Providers](#required-providers)
  - [Installation](#installation)
  - [Created Resources](#created-resources)
  - [Configuration Variables](#configuration-variables)
  - [Outputs](#outputs)
  - [Data Sources](#data-sources)
  - [IAM Policies Created](#iam-policies-created)
  - [Audit Logging](#audit-logging)
  - [Service Connector Hub](#service-connector-hub)
  - [Contributing](#contributing)
  - [Support](#support)

## Prerequisites

Before you begin, ensure you have the following:

1. Terraform installed on your local machine
2. OCI CLI installed and configured
3. Necessary OCI credentials (see [Configuration Variables](#configuration-variables))
4. Firefly access and secret keys

## Required Providers

This module requires the following Terraform providers. Add this block to your Terraform configuration:

```hcl
terraform {
  required_version = ">= 1.5.0"
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">=7.16.0"
    }
  }
}
```

Make sure to include this provider configuration in your Terraform files before using the Firefly OCI module.

## Installation

```hcl
provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region           = var.region
}

module "firefly_oci_integration" {
  source = "github.com/gofireflyio/terraform-firefly-oci-onboarding?ref=v1.0.0"
  
  # Required variables
  tenancy_ocid           = var.tenancy_ocid
  firefly_access_key     = var.firefly_access_key
  firefly_secret_key     = var.firefly_secret_key
  
  # Optional variables with defaults
  compartment_id         = var.compartment_id  # If null, uses tenancy root compartment
  user_ocid             = var.user_ocid        # Optional - for existing user
  region                = var.region           # Default: il-jerusalem-1
  prefix                = var.prefix           # Default: ""
  suffix                = var.suffix           # Default: ""
  tags                  = var.tags             # Default: {}
  firefly_endpoint      = var.firefly_endpoint # Default: https://api-env2.dev.firefly.ai/api
  
  # Optional - for using existing resources
  existing_user_id         = var.existing_user_id      # Use existing OCI user
  existing_group_id        = var.existing_group_id     # Use existing OCI group  
  existing_log_group_id    = var.existing_log_group_id # Use existing log group
  existing_dynamic_group_id = var.existing_dynamic_group_id # Use existing dynamic group
}
```

## Created Resources

The Terraform module will create the following OCI resources:

- **OCI IAM User**: `firefly-svc` - Service user for Firefly authentication
- **OCI IAM Group**: `firefly-svc-admin` - Group for managing Firefly user permissions  
- **OCI IAM User Group Membership**: Adds the Firefly user to the admin group
- **OCI API Key**: API key pair for the Firefly service user
- **OCI IAM Dynamic Group**: `firefly-dynamic-group` - For service connector permissions
- **OCI IAM Policy**: `firefly-svc-policy` - Comprehensive permissions for Firefly access
- **OCI Service Connector Hub**: `firefly-audit-connector` - Routes audit logs to Firefly's stream
- **Firefly Integration**: Registers the OCI tenancy with Firefly via API calls

## Deploy to OCI

[![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/gofireflyio/firefly-oracle-cloud-onboarding/releases/latest/download/terraform-firefly-oci-onboarding.zip)

### Optional Resources
If you don't provide existing resource IDs, the module will create new ones. You can reuse existing resources by providing their OCIDs via variables.

## Configuration Variables

### Required Variables
| Variable | Description | Type |
|----------|-------------|------|
| `tenancy_ocid` | OCI Tenancy OCID | string |
| `firefly_access_key` | Firefly access key for authentication | string |
| `firefly_secret_key` | Firefly secret key for authentication | string |

### Optional Variables
| Variable | Description | Type | Default |
|----------|-------------|------|---------|
| `compartment_id` | OCI Compartment OCID. If null, uses tenancy root compartment | string | null |
| `user_ocid` | OCI User OCID for existing user | string | "" |
| `region` | OCI region for resource deployment | string | "il-jerusalem-1" |
| `prefix` | Prefix for resource naming | string | "" |
| `suffix` | Suffix for resource naming | string | "" |
| `tags` | Tags to apply to created resources | map(string) | {} |
| `firefly_endpoint` | Firefly API endpoint | string | "https://api-env2.dev.firefly.ai/api" |
| `existing_user_id` | OCID of existing user to use instead of creating new one | string | null |
| `existing_group_id` | OCID of existing group to use instead of creating new one | string | null |
| `existing_log_group_id` | OCID of existing log group to use | string | "" |
| `existing_dynamic_group_id` | OCID of existing dynamic group to use | string | "" |
| `dynamic_group_name` | Name for the dynamic group | string | "firefly-dynamic-group" |
| `firefly_auth_policy` | Name for the auth policy | string | "firefly-auth-policy" |

**Security Note**: Store your Firefly credentials securely using environment variables or a `terraform.tfvars` file that is not committed to version control.

## Outputs

The module provides the following outputs:

| Output | Description |
|--------|-------------|
| `dynamic_group_id` | The OCID of the Firefly dynamic group |
| `service_connector_id` | The OCID of the Firefly service connector |
| `tenancy_info` | Information about the OCI tenancy (OCID, name, home region) |
| `compartment_info` | Information about the OCI compartment |
| `firefly_integration_config` | Firefly user OCID for the integration |
| `public_key` | Public key for the created API key |
| `fingerprint` | Fingerprint of the created API key |
| `integration_id` | Firefly integration ID |
| `status_code` | Status code from Firefly API integration |
| `response_body` | Response body from Firefly API integration |

## Data Sources

The module uses several OCI data sources to gather information about your environment:

- **Tenancy Information**: Gets details about your OCI tenancy
- **Region Information**: Retrieves region subscription details  
- **User Information**: Gets user details if `user_ocid` is provided
- **Availability Domains**: Gets availability domain information for the region
- **Existing Resources**: Checks for existing log groups and dynamic groups if specified
- **Identity Domains**: Retrieves identity domain information for user management
- **Firefly Stream Information**: Gets target stream IDs from Firefly API based on region

## IAM Policies Created

The module creates a comprehensive IAM policy (`firefly-svc-policy`) with the following permissions:

1. **Tenancy Cross-Reference**: Defines Firefly tenancy for cross-tenancy access
2. **Global Read Access**: `Allow group to read all-resources in tenancy`
3. **Service Connector Management**: `Allow group to manage serviceconnectors in compartment`
4. **Stream Push Permissions**: Endorses the group to push to streams in the Firefly tenancy for service connectors

These policies enable Firefly to:
- Discover and inventory all OCI resources in your tenancy
- Create and manage Service Connector Hub resources for audit log streaming
- Push audit logs to Firefly's managed streams for processing and analysis

## Audit Logging

The module automatically configures audit log streaming using OCI's built-in audit logging capabilities:
- **Source**: Uses the special `_Audit_Include_Subcompartment` log group which captures all audit events
- **Scope**: Includes all compartments and subcompartments under the specified compartment
- **Coverage**: Captures all administrative operations, API calls, and resource changes

## Service Connector Hub

The Service Connector Hub (`firefly-audit-connector`) is configured to:
- **Source**: OCI Audit Log Group (`_Audit_Include_Subcompartment`)
- **Target**: Firefly-managed OCI Stream (automatically determined by region)
- **Scope**: Compartment-level with subcompartment inclusion
- **Function**: Real-time streaming of audit events to Firefly for analysis and monitoring

The target stream is automatically selected based on your OCI region through Firefly's API.

## Contributing

We welcome contributions to the Firefly OCI Integration! If you have functionality that you think would be valuable to other Firefly customers, please feel free to submit a pull request.

When contributing, please:

1. Ensure your code is well-documented
2. Include a README or update the existing README with usage instructions
3. Test your code thoroughly before submitting

## Support

If you encounter any issues or have questions about using this repository, please open an issue on GitHub or contact Firefly support.

For more information about Firefly and our services, please visit [our website](https://www.gofirefly.io/).
