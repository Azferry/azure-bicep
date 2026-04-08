
$location       = "eastus" # Azure region for deployment
$resourcePrefix = "biceptesting"
$tags           = "Environment=Test Project=BicepTest"
$deploymentName = "BicepTest-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
$templateFile   = ".\main.bicep"
#endregion

Write-Host "Logging in to Azure..." -ForegroundColor Cyan
az login --use-device-code

Write-Host "Starting deployment: $deploymentName" -ForegroundColor Cyan

$deployment = az deployment sub create `
    --name $deploymentName `
    --location $location `
    --template-file $templateFile `
    --parameters location=$location resourcePrefix=$resourcePrefix `
    | ConvertFrom-Json

if ($deployment.properties.provisioningState -eq "Succeeded") {
    Write-Host "Deployment succeeded." -ForegroundColor Green
} else {
    Write-Host "Deployment finished with state: $($deployment.properties.provisioningState)" -ForegroundColor Yellow
}
