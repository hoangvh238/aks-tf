# ===============================
# deploy-aks.ps1
# ===============================

Write-Host "Logging in to Azure..."
az login --use-device-code


$subscriptionId = "536aee0e-3a70-4edd-bea8-8cdac15c86e4"
$tenantId = "8d3b84f1-bf98-40ba-942d-79f442d85a58"
$region = "eastus"  # Changed to eastus for lower cost

Write-Host "Setting subscription..."
az account set --subscription $subscriptionId

Write-Host "Current Azure account:"
az account show --output table

Write-Host "Initializing Terraform..."
terraform init

Write-Host "Running Terraform plan..."
terraform plan -var "region=$region" -out=tfplan

if ($LASTEXITCODE -ne 0) {
    Write-Error "Terraform plan failed. Exiting."
    exit 1
}

Write-Host "Applying Terraform plan..."
terraform apply -auto-approve tfplan

Write-Host "Deployment complete!"
