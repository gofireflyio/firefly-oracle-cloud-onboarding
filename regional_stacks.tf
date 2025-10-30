# Regional Stack Orchestration - Creates ORM stacks per region
# Following DataDog's pattern for multi-region OCI deployments

# Create ZIP file of regional stack terraform code
resource "terraform_data" "regional_stack_zip" {
  count    = var.managed_service_connector ? 0 : 1
  depends_on = [null_resource.firefly_validation]

  provisioner "local-exec" {
    working_dir = "${path.module}/modules/regional-stacks"
    command     = "rm -f firefly_regional_stack.zip && zip -r firefly_regional_stack.zip ./*.tf"
  }

  triggers_replace = {
    "key" = timestamp()
  }
}

# Create a unique identifier for this stack deployment
resource "terraform_data" "stack_digest" {
  count    = var.managed_service_connector ? 0 : 1
  depends_on = [null_resource.firefly_validation]

  provisioner "local-exec" {
    working_dir = path.module
    command     = "echo $JOB_ID"
  }
}

# Deploy regional ORM stacks for each subscribed region
resource "null_resource" "regional_stacks_create_apply" {
  depends_on = [
    null_resource.firefly_validation,
    terraform_data.regional_stack_zip,
    terraform_data.stack_digest,
    oci_identity_policy.firefly_auth_policy
  ]

  for_each = var.managed_service_connector ? toset([]) : local.target_regions_set

  provisioner "local-exec" {
    working_dir = path.module
    command     = <<EOT
    # Suppress OCI CLI warnings
    export OCI_CLI_SUPPRESS_FILE_PERMISSIONS_WARNING=True

    echo "Creating/updating Firefly regional stack in region: ${each.key}"

    STACK_NAME="firefly-regional-stack-${terraform_data.stack_digest.id}"

    # Check for existing stacks with the same name in this region
    STACK_IDS=($(oci --region ${each.key} resource-manager stack list --display-name $STACK_NAME --compartment-id ${local.firefly_compartment_id} --raw-output 2>/dev/null | jq -r '.data[]."id"' 2>/dev/null))
    STACK_ID=''

    if [[ -z "$STACK_IDS" ]]; then
      echo "No existing stack found. Creating new stack in region ${each.key}..."
      STACK_ID=$(oci resource-manager stack create \
        --compartment-id ${local.firefly_compartment_id} \
        --display-name $STACK_NAME \
        --config-source ${path.module}/modules/regional-stacks/firefly_regional_stack.zip --variables '{"tenancy_ocid": "${var.tenancy_ocid}", "compartment_ocid": "${local.firefly_compartment_id}", \
        "region": "${each.key}", "home_region": "${data.oci_identity_tenancy.current.home_region_key}", "display_name": "firefly-audit-connector", "target_stream_id": "${lookup(local.firefly_stream_ids_map, each.key, "")}"}' \
        --wait-for-state ACTIVE \
        --max-wait-seconds 120 \
        --wait-interval-seconds 5 \
        --query "data.id" --raw-output --region ${each.key})
      echo "Created Stack ID: $STACK_ID in region ${each.key}"
    else
      echo "Found existing stack: $${STACK_IDS[@]}"
      STACK_ID="$${STACK_IDS[@]:0:1}"
    fi

    # Create apply job
    echo "Creating apply job for stack: $STACK_ID in region ${each.key}"

    for attempt in {1..5}; do
      echo "Attempting to create job (attempt $attempt/5)..."
      if JOB_ID=$(oci resource-manager job create-apply-job \
        --stack-id $STACK_ID \
        --execution-plan-strategy AUTO_APPROVED \
        --region ${each.key} \
        --query "data.id" \
        --raw-output 2>/dev/null); then
        echo "Job created successfully: $JOB_ID for region ${each.key}"
        break
      else
        echo "Job creation failed on attempt $attempt"
        if [ $attempt -lt 5 ]; then
          echo "Waiting 6 seconds before retry..."
          sleep 6
        fi
      fi
    done

    if [ -z "$JOB_ID" ]; then
      echo "WARNING: Failed to create job after 5 attempts for region ${each.key}. Continuing..."
    fi
   EOT
  }

  triggers = {
    always_run = timestamp()
  }
}

# Destroy regional stacks on destroy
resource "terraform_data" "regional_stacks_destroy" {
  depends_on = [
    terraform_data.regional_stack_zip,
    terraform_data.stack_digest
  ]

  for_each = var.managed_service_connector ? toset([]) : local.target_regions_set

  input = {
    compartment     = local.firefly_compartment_id
    stack_digest_id = terraform_data.stack_digest.id
  }

  provisioner "local-exec" {
    when        = destroy
    working_dir = path.module
    command     = <<EOT
    export OCI_CLI_SUPPRESS_FILE_PERMISSIONS_WARNING=True

    STACK_NAME="firefly-regional-stack-${self.input.stack_digest_id}"
    COMPARTMENT_ID="${self.input.compartment}"

    echo "Deleting Firefly regional stack in region: ${each.key}"

    # Find and delete the stack
    STACK_IDS=($(oci --region ${each.key} resource-manager stack list --display-name $STACK_NAME --compartment-id $COMPARTMENT_ID --raw-output 2>/dev/null | jq -r '.data[]."id"' 2>/dev/null))
    if [[ -z "$STACK_IDS" ]]; then
      echo "No stacks found in the compartment."
      exit 0
    fi
    
    echo "Found... stack... Ids: $${STACK_IDS[@]}"
    for STACK_ID in "$${STACK_IDS[@]}"; do
      echo "Running...destroy...job...for...stack...: $STACK_ID"
    
      JOB_ID=$(oci --region ${each.key} resource-manager job create-destroy-job \
        --stack-id "$STACK_ID" --wait-for-state SUCCEEDED --wait-for-state FAILED \
        --execution-plan-strategy AUTO_APPROVED \
        --query "data.id" --raw-output)
      
      if [[ -z "$JOB_ID" ]]; then
        echo "Destroy job not successfully completed."
        exit 1
      fi
    
      echo "Waiting....for.....destroy....job....($JOB_ID)....to....complete..."
    
      echo "Deleting....stack: $STACK_ID"
      oci --region ${each.key} resource-manager stack delete --stack-id "$STACK_ID" --force
    done
    
    echo "All stacks destroyed for the region: ${each.key}."
EOT
  }
}
