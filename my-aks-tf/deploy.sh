#!/bin/bash

SUBSCRIPTION_ID="536aee0e-3a70-4edd-bea8-8cdac15c86e4"
TENANT_ID="8d3b84f1-bf98-40ba-942d-79f442d85a58"

echo "Logging into Azure..."
az login --tenant $TENANT_ID

echo "Setting subscription to dev-azure..."
az account set --subscription $SUBSCRIPTION_ID

echo "Verifying current subscription..."
az account show -o table

echo "Initializing Terraform..."
terraform init

if [ ! -f "terraform.tfvars" ]; then
    echo "Creating terraform.tfvars..."
    cat > terraform.tfvars << EOF
# Azure Configuration
az_region = "eastus"  # Cheaper region compared to Southeast Asia
az_env    = "demo"
az_tags = {
  environment = "demo"
  project     = "aks"
}

# AKS Configuration
nodepools = {
  worker = {
    name        = "worker"
    vm_size     = "Standard_B2s"
    node_count  = 1
    tags        = { worker_name = "worker" }
    node_labels = { "worker-name" = "worker" }
  }
}
EOF
fi

echo "Planning Terraform deployment..."
terraform plan -out=tfplan

read -p "Do you want to proceed with the deployment? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    echo "Applying Terraform configuration..."
    terraform apply tfplan
else
    echo "Deployment cancelled"
fi
