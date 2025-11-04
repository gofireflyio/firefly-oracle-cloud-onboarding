# Firefly OCI Integration

![Firefly Logo](firefly.gif)

This Terraform module automates the complete integration of Firefly with Oracle Cloud Infrastructure (OCI). It creates all necessary OCI IAM resources, establishes secure authentication, sets up audit log streaming via Service Connector Hub, and registers your OCI tenancy with Firefly for comprehensive cloud asset management and monitoring.

## Table of Contents

- [Firefly OCI Integration](#firefly-oci-integration)
  - [Table of Contents](#table-of-contents)
  - [Prerequisites](#prerequisites)
  - [Required Providers](#required-providers)
  - [Quick Start](#quick-start)
  - [Installation](#installation)
  - [Created Resources](#created-resources)
  - [Configuration Variables](#configuration-variables)
  - [Using terraform.tfvars](#using-terraformtfvars)
  - [Compartment Management](#compartment-management)
  - [Integration Request Handling](#integration-request-handling)
  - [Outputs](#outputs)
  - [Data Sources](#data-sources)
  - [IAM Policies Created](#iam-policies-created)
  - [Service Connector Hub](#service-connector-hub)
  - [Event Filtering](#event-filtering)
  - [Troubleshooting](#troubleshooting)
  - [Contributing](#contributing)
  - [Support](#support)

## Prerequisites

Before you begin, ensure you have the following:

1. **Terraform** (version >= 1.5.0) installed on your local machine
2. **OCI CLI** installed and configured
3. **OCI Credentials**:
   - Tenancy OCID
   - Current user OCID (required for identity domain lookup)
   - User fingerprint and private key
   - Appropriate permissions to create IAM resources in your tenancy
4. **Firefly Credentials**:
   - Firefly access key
   - Firefly secret key
5. **OCI Region** where you want to deploy the integration

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

## Quick Start

1. **Clone or download this repository** to your local machine
2. **Create a `terraform.tfvars` file** with your credentials (see [Using terraform.tfvars](#using-terraformtfvars) below)
3. **Run the following commands**:

```bash
# Initialize Terraform
terraform init

# Preview the changes
terraform plan

# Create the resources (first apply with integration API call)
terraform apply

# For subsequent applies, set skip_integration_request = true
terraform apply -var skip_integration_request=true

# For destroy operations, also set skip_integration_request = true
terraform destroy -var skip_integration_request=true
```

## Installation

### Direct Deployment

If you're using this module directly in your Terraform configuration:

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
  current_user_ocid      = var.current_user_ocid
  region                 = var.region

  # Optional variables with defaults
  compartment_ocid          = var.compartment_ocid       # If null, creates "Firefly" compartment
  domain_id                 = var.domain_id              # Identity domain for user/group management
  prefix                    = var.prefix                 # Default: ""
  suffix                    = var.suffix                 # Default: ""
  tags                      = var.tags                   # Default: {}
  firefly_endpoint          = var.firefly_endpoint       # Default: https://prodapi.firefly.ai/api

  # Optional - for using existing resources
  existing_user_id          = var.existing_user_id           # Use existing OCI user
  existing_group_id         = var.existing_group_id          # Use existing OCI group
  existing_dynamic_group_id = var.existing_dynamic_group_id  # Use existing dynamic group

  # Optional - service connector and event-driven configuration
  managed_service_connector = var.managed_service_connector # Default: true
  event_driven_regions      = var.event_driven_regions       # Default: []
  is_prod                   = var.is_prod                    # Default: true
  integrationSessionId      = var.integrationSessionId       # Default: null
  skip_integration_request  = var.skip_integration_request   # Default: false
}
```

## Created Resources

The Terraform module will create the following OCI resources:

- **OCI IAM User**: `firefly-svc` - Service user for Firefly authentication
- **OCI IAM Group**: `firefly-svc-admin` - Group for managing Firefly user permissions  
- **OCI IAM User Group Membership**: Adds the Firefly user to the admin group
- **OCI API Key**: API key pair for the Firefly service user
- **OCI IAM Dynamic Group**: `firefly-dynamic-group` - For service connector permissions (created only if `existing_dynamic_group_id` is not provided)
- **OCI IAM Policy**: `firefly-svc-policy` - Comprehensive permissions for Firefly access
- **OCI Service Connector Hub**: `firefly-audit-connector` - Routes audit logs to Firefly's stream (created only if `create_service_connector` is set to `true`)
- **Firefly Integration**: Registers the OCI tenancy with Firefly via API calls

## Deploy to OCI

[![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/gofireflyio/firefly-oracle-cloud-onboarding/releases/download/v1.0.1/terraform-firefly-oci-onboarding.zip)

### Optional Resources
If you don't provide existing resource IDs, the module will create new ones. You can reuse existing resources by providing their OCIDs via variables.

## Configuration Variables

### Required Variables
| Variable | Description | Type |
|----------|-------------|------|
| `tenancy_ocid` | OCI Tenancy OCID | string |
| `region` | OCI region for resource deployment | string |
| `current_user_ocid` | OCI User OCID for the current user (required for identity domain lookup) | string |
| `firefly_access_key` | Firefly access key for authentication | string |
| `firefly_secret_key` | Firefly secret key for authentication | string |

### Optional Variables - Compartment and Identity Domain Management
| Variable | Description | Type | Default |
|----------|-------------|------|---------|
| `compartment_ocid` | OCID of the compartment to use for Firefly resources. If null, a compartment named 'Firefly' will be auto-created in the tenancy | string | null |
| `domain_id` | OCID of the identity domain to use for user and group management. If not provided, an intelligent selection process is used | string | "" |

### Optional Variables - API Configuration
| Variable | Description | Type | Default |
|----------|-------------|------|---------|
| `firefly_endpoint` | Firefly API endpoint | string | "https://prodapi.firefly.ai/api" |
| `integration_session_id` | Integration session ID for tracking | string | null |
| `skip_integration_request` | Skip the HTTP integration request (useful for destroy operations and subsequent applies) | bool | false |

### Optional Variables - Naming and Tagging
| Variable | Description | Type | Default |
|----------|-------------|------|---------|
| `prefix` | Prefix for resource naming | string | "" |
| `suffix` | Suffix for resource naming | string | "" |
| `tags` | Tags to apply to created resources | map(string) | {} |
| `dynamic_group_name` | Name for the dynamic group | string | "firefly-dynamic-group" |
| `firefly_auth_policy` | Name for the auth policy | string | "firefly-auth-policy" |

### Optional Variables - Resource Reuse
| Variable | Description | Type | Default |
|----------|-------------|------|---------|
| `existing_user_id` | OCID of existing user to use instead of creating new one | string | null |
| `existing_group_id` | OCID of existing group to use instead of creating new one | string | null |
| `existing_dynamic_group_id` | OCID of existing dynamic group to use | string | "" |

### Optional Variables - Service Connector and Event-Driven
| Variable | Description | Type | Default |
|----------|-------------|------|---------|
| `managed_service_connector` | Whether to let Firefly manage the service connector | bool | true |
| `event_driven_regions` | List of OCI regions for event-driven integration (service connectors will be created in each region) | list(string) | [] |
| `is_prod` | Whether this is a production environment | bool | true |
| `integrationSessionId` | Integration session ID for tracking | string | null |

**Security Note**: Store your Firefly credentials securely using environment variables or a `terraform.tfvars` file that is not committed to version control.

## Using terraform.tfvars

Create a `terraform.tfvars` file in the same directory as your Terraform configuration with the following structure:

```hcl
# Required credentials
firefly_access_key = "your_firefly_access_key_here"
firefly_secret_key = "your_firefly_secret_key_here"

# Required OCI details
tenancy_ocid     = "ocid1.tenancy.oc1..aaaaaaaaxxx..."
current_user_ocid = "ocid1.user.oc1..aaaaaaaaxxx..."
region           = "eu-frankfurt-1"  # or your preferred OCI region

# Optional: Specify compartment and domain
# compartment_ocid = "ocid1.compartment.oc1..aaaaaaaaxxx..."  # Leave null to auto-create Firefly compartment
# domain_id = "ocid1.domain.oc1..aaaaaaaaxxx..."               # Leave blank to use default domain

# Optional: Configure service connectors
managed_service_connector = true
event_driven_regions = ["eu-frankfurt-1", "us-phoenix-1"]

# Optional: Add custom tags
tags = {
  Environment = "production"
  Owner       = "platform-team"
  CostCenter  = "engineering"
}
```

**⚠️ Important**: Add `terraform.tfvars` to your `.gitignore` file to prevent accidental credential exposure:

```bash
echo "terraform.tfvars" >> .gitignore
```

## Compartment Management

The Firefly OCI integration uses an intelligent compartment selection strategy:

### Compartment Selection Priority

1. **User-Provided Compartment** (via `compartment_ocid` variable): If you specify a compartment OCID, all Firefly application resources will be created in that compartment
2. **Auto-Created Firefly Compartment** (default): If `compartment_ocid` is null (not provided), the module automatically creates a new compartment named "Firefly" in your tenancy root

### Important Notes

- **Identity Resources** (users, groups, policies, dynamic groups) are ALWAYS created in the root tenancy, regardless of the `compartment_ocid` setting. This is an OCI requirement.
- **Application Resources** (service connectors, audit log configurations) are created in the specified or auto-created Firefly compartment
- To use an existing compartment, provide its OCID in `terraform.tfvars`:
  ```hcl
  compartment_ocid = "ocid1.compartment.oc1..aaaaaaaaxxx..."
  ```

## Identity Domain Management

The module uses an intelligent identity domain selection process for creating users and groups in the appropriate domain. This is important in OCI tenancies with multiple identity domains.

### Domain Selection Process

When you don't explicitly provide a `domain_id`, the module follows this fallback logic:

1. **Explicit Domain** (if provided): Uses the `domain_id` variable you specify
2. **Existing User's Domain**: If you provide an `existing_user_id`, uses the domain where that user exists
3. **Current User's Domain**: Falls back to the domain of the `current_user_ocid` (the user running Terraform)
4. **Default Domain**: If none of the above can be determined, uses the tenancy's default domain

### Specifying a Domain

To explicitly specify an identity domain:

```hcl
domain_id = "ocid1.domain.oc1..aaaaaaaaxxx..."
```

This ensures users and groups are created in the specified domain rather than relying on automatic detection.

## Integration Request Handling

The Firefly integration module makes an HTTP request to the Firefly API to register your OCI tenancy. This request happens during `terraform apply` and returns the API key details needed for authentication.

### Managing Integration Requests

**First Apply (Initial Setup)**:
```bash
# Leave skip_integration_request at default (false) to make the API call
terraform apply
```

**Subsequent Applies**:
```bash
# Set skip_integration_request = true to skip the API call and avoid recreating API keys
terraform apply -var skip_integration_request=true
```

**Destroy Operations**:
```bash
# Set skip_integration_request = true to skip the API call during destruction
terraform destroy -var skip_integration_request=true
```

### Why Skip Integration Request?

- **Avoid Duplicate API Keys**: The Firefly API returns a public key that is uploaded to OCI. On subsequent applies, if you don't skip, it tries to create duplicate API keys
- **Faster Operations**: Skipping the API call reduces apply time for updates
- **Clean Destruction**: During destroy, you don't need to call the Firefly API again

### Troubleshooting Integration Errors

If you encounter "key must not be empty" errors:
1. Verify your Firefly credentials are correct
2. Check network connectivity to `https://prodapi.firefly.ai/api`
3. Review the Firefly API response: Check `module.firefly_oci_integration.response_body` output
4. For subsequent operations, always set `skip_integration_request = true`

## Outputs

The module provides the following outputs:

| Output | Description |
|--------|-------------|
| `firefly_compartment_id` | The OCID of the Firefly compartment (auto-created or user-provided) |
| `firefly_compartment_created` | Whether a new Firefly compartment was created |
| `dynamic_group_id` | The OCID of the Firefly dynamic group |
| `tenancy_info` | Information about the OCI tenancy (OCID, name) |
| `compartment_info` | Information about the OCI compartment used for Firefly resources |
| `firefly_integration_config` | Firefly user OCID for the integration |
| `public_key` | Public key for the created API key |
| `fingerprint` | Fingerprint of the created API key |
| `integration_id` | Firefly integration ID |
| `response_message` | Response body from Firefly API integration |

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

The module creates a comprehensive IAM policy (`firefly-svc-policy`) with the following specific statements:

1. **Tenancy Cross-Reference**: `Define tenancy Firefly as ocid1.tenancy.oc1..aaaaaaaahxrxe37ndpd3xidrt4laffdtxhdaq4srccux3cumrugervil4inq` - Defines Firefly tenancy for cross-tenancy access
2. **Global Read Access**: `Allow group to read all-resources in tenancy` - Enables Firefly to discover and inventory all OCI resources
3. **Service Connector Management**: `Allow group to manage serviceconnectors in compartment` - Allows creation and management of Service Connector Hub resources
4. **Stream Push Permissions**: `Endorse group to use stream-push in tenancy Firefly` - Enables the group to push audit logs to Firefly's managed streams (with conditions for service connectors)

These policies enable Firefly to:
- Discover and inventory all OCI resources in your tenancy
- Create and manage Service Connector Hub resources for audit log streaming (when enabled)
- Push audit logs to Firefly's managed streams for processing and analysis

## Audit Logging

The module automatically configures audit log streaming using OCI's built-in audit logging capabilities:
- **Source**: Uses the special `_Audit_Include_Subcompartment` log group which captures all audit events
- **Scope**: Includes all compartments and subcompartments under the specified compartment
- **Coverage**: Captures all administrative operations, API calls, and resource changes

## Service Connector Hub

The Service Connector Hub is an optional component that can be configured using the `managed_service_connector` and `event_driven_regions` variables. When `event_driven_regions` is set to a non-empty list, service connectors are created in those OCI regions. The `managed_service_connector` variable controls whether Firefly manages the connector (default: `true`).

### Service Connector Configuration

Each service connector is configured as follows:
- **Source**: OCI Audit Log Group (`_Audit_Include_Subcompartment`) - captures all audit events
- **Task**: LogRule filter with comprehensive OCI event filtering
- **Target**: Firefly-managed OCI Stream (automatically determined by region via Firefly API)
- **Scope**: Compartment-level with subcompartment inclusion
- **Function**: Real-time streaming of filtered audit events to Firefly for analysis and monitoring

### Multi-Region Deployment

To enable service connectors in multiple regions:

```hcl
event_driven_regions = ["eu-frankfurt-1", "us-phoenix-1", "eu-amsterdam-1"]
managed_service_connector = true
```

This will create one service connector per specified region, each with region-specific naming and configuration.

### Automatic Target Stream Selection

The target stream is automatically selected based on your OCI region through Firefly's API:
1. The integration module queries Firefly API for available stream IDs per region
2. Service connectors are created with the appropriate stream ID for each region
3. Audit events flow directly to Firefly's regional streams for processing

**Note**: By default, no service connectors are created (`event_driven_regions = []`). Specify one or more regions in `event_driven_regions` to enable audit log streaming to Firefly.

## Event Filtering

Service Connectors are configured with comprehensive OCI event filtering to capture security and operational events. The filter includes 50+ OCI events organized by category:

### Event Categories Included

- **Object Storage**: CreateBucket, UpdateBucket, DeleteBucket, etc.
- **Identity & Access Management**: CreateUser, UpdateUser, CreateGroup, CreatePolicy, etc.
- **Compute**: LaunchInstance, TerminateInstance, UpdateInstance, etc.
- **Database**: CreateDbSystem, DeleteDbSystem, UpdateDbSystem, etc.
- **Networking**: CreateVcn, UpdateSecurityList, CreateNetworkSecurityGroup, etc.
- **Storage**: CreateBlockchainPlatform, DeleteBlockchainPlatform, etc.
- **Security**: UpdateSecurityList, CreateNetworkSecurityGroup, etc.

The complete list of filtered events is dynamically configured in the service connector's LogRule task condition, ensuring all critical OCI operations are captured and streamed to Firefly for analysis.

## Troubleshooting

### Common Issues and Solutions

#### Issue: "key must not be empty" error during terraform apply

**Cause**: The Firefly integration API didn't return a public key
**Solutions**:
1. Verify Firefly credentials are correct in `terraform.tfvars`
2. Check network connectivity to `https://prodapi.firefly.ai/api`
3. Review the error response: Check the `module.firefly_oci_integration.response_body` output
4. For subsequent applies, always set `skip_integration_request = true`

#### Issue: "Tenant id is not equal to compartment id" error

**Cause**: Attempting to create OCI Identity resources (users, groups, policies) in a sub-compartment
**Solution**: This is correctly handled - Identity resources are created in the root tenancy, while application resources are created in the Firefly compartment

#### Issue: "Dynamic group can only be created in the tenancy compartment" error

**Cause**: Same as above
**Solution**: This is correctly handled in the current configuration

#### Issue: Service connector not receiving audit events

**Cause**: Multiple possible causes
**Solutions**:
1. Verify the dynamic group matching rule is correct: `All {resource.type = 'serviceconnector'}`
2. Ensure the service connector has proper permissions (check IAM policies)
3. Verify the audit log group is properly configured
4. Check that events are actually being generated in the specified compartment
5. Review OCI Logging service for any configuration issues

#### Issue: Terraform plan/apply is slow

**Cause**: Integration API calls or data source queries
**Solutions**:
1. Use `skip_integration_request = true` for subsequent applies
2. Reduce the number of regions in `event_driven_regions` if not needed
3. Verify network connectivity and Firefly API availability

### Getting Help

If issues persist:
1. Check Terraform debug output: `TF_LOG=DEBUG terraform plan`
2. Review OCI IAM policies and ensure proper permissions
3. Contact Firefly support with relevant error messages and Terraform output
4. Open an issue on the GitHub repository with details about your environment and error

## Contributing

We welcome contributions to the Firefly OCI Integration! If you have functionality that you think would be valuable to other Firefly customers, please feel free to submit a pull request.

When contributing, please:

1. Ensure your code is well-documented
2. Include a README or update the existing README with usage instructions
3. Test your code thoroughly before submitting

## Support

If you encounter any issues or have questions about using this repository, please open an issue on GitHub or contact Firefly support.

For more information about Firefly and our services, please visit [our website](https://www.gofirefly.io/).
