terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 5.0"
    }
  }
}

# Create regional stack zip file
resource "terraform_data" "regional_stack_zip" {
  provisioner "local-exec" {
    working_dir = "${path.module}"
    command     = "rm -f firefly_regional_stack.zip && zip -r firefly_regional_stack.zip ./*.tf"
  }
  triggers_replace = {
    "key" = timestamp()
  }
}

# Create ORM stacks in target regions
resource "null_resource" "regional_stacks_create_apply" {
  depends_on = [terraform_data.regional_stack_zip]
  for_each = var.target_regions
  
  provisioner "local-exec" {
    working_dir = path.module
    command     = <<EOT
      echo "Creating Firefly regional stack in region ${each.key}"
      
      # Stack name unique to this deployment
      STACK_NAME="firefly-regional-stack-${random_id.stack_digest.hex}"
      
      # Check for existing stack
      STACK_IDS=($(oci --region ${each.key} resource-manager stack list --display-name $STACK_NAME --compartment-id ${var.compartment_id} --raw-output | jq -r '.data[]."id"'))
      STACK_ID=''
      
      if [[ -z "$STACK_IDS" ]]; then
        echo "Creating new stack in region ${each.key}"
        STACK_ID=$(oci resource-manager stack create --compartment-id ${var.compartment_id} --display-name $STACK_NAME \
        --config-source ${path.module}/firefly_regional_stack.zip \
        --variables '{"tenancy_ocid": "${var.tenancy_ocid}", "region": "${each.key}", \
        "compartment_id": "${var.compartment_id}", "firefly_access_key_secret_id": "${var.firefly_access_key_secret_id}", \
        "firefly_secret_key_secret_id": "${var.firefly_secret_key_secret_id}", \
        "dynamic_group_id": "${var.dynamic_group_id}", "log_group_id": "${var.log_group_id}", \
        "target_stream_id": "${var.target_stream_id}", "home_region": "${var.home_region}"}' \
        --query "data.id" --raw-output --region ${each.key})
        echo "Created Stack ID: $STACK_ID in region ${each.key}"
      else
        echo "Found existing stack: $${STACK_IDS[@]:0:1}"
        STACK_ID="$${STACK_IDS[@]:0:1}"
      fi
      
      # Create and apply job
      echo "Applying stack: $STACK_ID in region ${each.key}"
      JOB_ID=$(oci resource-manager job create-apply-job --stack-id $STACK_ID \
      --execution-plan-strategy AUTO_APPROVED --region ${each.key} --query "data.id" --raw-output)
      
      echo "Apply job created: $JOB_ID in region ${each.key}"
    EOT
  }

  triggers = {
    always_run = timestamp()
  }
}

# Generate unique stack digest
resource "random_id" "stack_digest" {
  byte_length = 8
}
