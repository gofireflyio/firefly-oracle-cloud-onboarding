# Firefly OCI Integration

![Firefly Logo](firefly.gif)

This repository contains Terraform modules for integrating Firefly with Oracle Cloud Infrastructure (OCI). It allows you to set up the necessary resources and permissions for Firefly to monitor and manage your OCI environment.

## Table of Contents

- [Firefly OCI Integration](#firefly-oci-integration)
  - [Table of Contents](#table-of-contents)
  - [Prerequisites](#prerequisites)
  - [Required Providers](#required-providers)
  - [Installation](#installation)
  - [Required Resources](#required-resources)
  - [Configuration Variables](#configuration-variables)
  - [Data Sources](#data-sources)
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
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 5.0"
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

module "firefly_oci" {
  source = "github.com/gofireflyio/terraform-firefly-oci-onboarding?ref=v1.0.0"
  
  tenancy_ocid = var.tenancy_ocid
  compartment_id = var.compartment_id
  user_ocid = var.user_ocid  # Optional
  
  firefly_access_key = var.firefly_access_key
  firefly_secret_key = var.firefly_secret_key
  
  region = var.region
  prefix = var.prefix
  tags  = var.tags
  
  # Service Connector Hub target stream
  target_stream_id = var.target_stream_id
}
```

## Required Resources

The Terraform module will create the following OCI resources:

- OCI IAM Dynamic Group
- OCI IAM Policies for connector hub and audit logging
- OCI Audit Log Configuration
- OCI Service Connector Hub
- OCI Log Group for Audit Logs
- OCI Log Configuration

## Configuration Variables

| Variable | Description | Required |
|----------|-------------|----------|
| `tenancy_ocid` | OCI Tenancy OCID | Yes |
| `compartment_id` | OCI Compartment OCID | Yes |
| `user_ocid` | OCI User OCID (optional) | No |
| `firefly_access_key` | Firefly access key | Yes |
| `firefly_secret_key` | Firefly secret key | Yes |
| `region` | OCI region for resource deployment | No (default: us-ashburn-1) |
| `prefix` | Prefix for resource naming | No |
| `tags` | Tags to apply to created resources | No |
| `target_stream_id` | OCI Stream OCID for Service Connector Hub target | Yes |

Ensure you have these variables set in your Terraform configuration or provide them securely using environment variables or a `terraform.tfvars` file.

## Data Sources

The module uses several OCI data sources to gather information about your environment:

- **Tenancy Information**: Gets details about your OCI tenancy
- **Compartment Information**: Retrieves compartment details and metadata
- **User Information**: Gets user details if `user_ocid` is provided
- **Region Information**: Retrieves region subscription details
- **Existing Resources**: Checks for existing log groups and dynamic groups
- **Target Stream**: Validates and gets information about the target stream
- **Availability Domains**: Gets availability domain information for the region

## IAM Policies Created

The module creates the following IAM policies:

1. **Firefly Connector Hub Policy**: Allows Firefly to manage Service Connector Hub resources
2. **Firefly Audit Logging Policy**: Allows Firefly to read audit logs and manage log configurations
3. **Firefly Stream Policy**: Allows Firefly to read from the target stream

## Audit Logging

The module enables comprehensive audit logging for:
- Administrative operations
- Data plane operations
- Identity operations
- Security operations

## Service Connector Hub

The Service Connector Hub is configured to:
- Source: Audit Log Group
- Target: OCI Stream (configurable via variable)
- Filters: All audit log categories

## Contributing

We welcome contributions to the Firefly OCI Integration! If you have functionality that you think would be valuable to other Firefly customers, please feel free to submit a pull request.

When contributing, please:

1. Ensure your code is well-documented
2. Include a README or update the existing README with usage instructions
3. Test your code thoroughly before submitting

## Support

If you encounter any issues or have questions about using this repository, please open an issue on GitHub or contact Firefly support.

For more information about Firefly and our services, please visit [our website](https://www.gofirefly.io/).
