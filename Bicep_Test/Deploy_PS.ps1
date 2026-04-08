### Requires the install of AZ Powershell Modules

Import-Module Az.Resources

$location       = "eastus" # Azure region for deployment
$resourcePrefix = "biceptesting"
$tags           = @{
    Environment = "Test"
    Project     = "BicepTest"
}
$deploymentName = "BicepTest-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
$templateFile   = ".\main.bicep"

Write-Host "Logging in to Azure..." -ForegroundColor Cyan
Connect-AzAccount

#region Deploy Bicep
Write-Host "Starting deployment: $deploymentName" -ForegroundColor Cyan

$deploymentParams = @{
    Name                  = $deploymentName
    Location              = $location
    TemplateFile          = $templateFile
    TemplateParameterObject = @{
        location       = $location
        resourcePrefix = $resourcePrefix
        tags           = $tags
    }
}

$deployment = New-AzDeployment @deploymentParams

if ($deployment.ProvisioningState -eq "Succeeded") {
    Write-Host "Deployment succeeded." -ForegroundColor Green
} else {
    Write-Host "Deployment finished with state: $($deployment.ProvisioningState)" -ForegroundColor Yellow
}
