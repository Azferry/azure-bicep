param (
    [string]$AzRegion,    
    [string]$BuChargeBackCode,
    [string]$AzRgPrefix
)
# .\run.ps1 -AzRegion "eastus2" -BuChargeBackCode "001" -AzRgPrefix "MyRg"
### Deployment Variables ###

$today = Get-Date -Format "MM-dd-yyyy_HHmmss"
$deploymentName = "RgDeployment-" + "$today"
$scriptPath = ".\main.bicep"

### Bicep Template variables
$deploymentLocation = "eastus2"
$resourceGroupName = $AzRgPrefix + "-rg"
$chargeBackCode = $BuChargeBackCode

New-AzSubscriptionDeployment -Name $deploymentName `
    -Location $deploymentLocation `
    -TemplateFile $scriptPath `
    -chargecode $chargeBackCode `
    -resourceGroupLocation $deploymentLocation `
    -resourceGroupName $resourceGroupName