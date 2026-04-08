### Requires the install of AZ Powershell Modules

Import-Module Az.Resources


function New-VMResourceGroup {
    param(
        [string]$Name,
        [string]$Location = 'eastus2',
        [hashtable]$Tags = @{}
    )
    
    $rg = Get-AzResourceGroup -Name $Name -ErrorAction SilentlyContinue
    if (-not $rg) {
        Write-Host "Creating resource group: $Name" -ForegroundColor Yellow
        New-AzResourceGroup -Name $Name -Location $Location -Tag $Tags
        Write-Host "Resource group created successfully" -ForegroundColor Green
    } else {
        Write-Host "Resource group $Name already exists" -ForegroundColor Cyan
    }
}

# ========================
$location       = "eastus2" # Azure region for deployment
$resourceGroupName = 'biceptesting-rg'
$tags           = @{
    Environment = "Test"
    Project     = "BicepTest"
}
$deploymentName = "BicepMultiVM-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
$templateFile   = ".\main.bicep"

# ========================

Write-Host "Logging in to Azure..." -ForegroundColor Cyan
Connect-AzAccount

Write-Host "Starting deployment: $deploymentName" -ForegroundColor Cyan


New-VMResourceGroup -Name $resourceGroupName -Location $location -Tags $tags

$deploymentParams = @{
    Name                  = $deploymentName
    Location              = $location
    ResourceGroupName     = $resourceGroupName
    TemplateFile          = $templateFile
    TemplateParameterObject = @{
        # Basic Configuration
        location                    = $location
        vmNamePrefix                = 'myVM'           # VMs will be named myVM-1, myVM-2, etc.
        vmCount                     = 1                # Number of VMs to deploy
        vmSize                      = 'Standard_D2ls_v5'
        osType                      = 'Linux'
        adminUsername               = 'azAdmin'
        # adminPassword               = '' # Use secure string in production
        
        # Image Reference
        imageReferencePublisher     = 'RedHat'
        imageReferenceOffer         = 'RHEL'
        imageReferenceSku           = '8-lvm-gen2'
        imageReferenceVersion       = 'latest'
        
        # Disk Encryption Set
        diskEncryptionSetId         = ''
        
        # Network / Subnet
        subnetId                    = ''
        privateIPAllocationMethod   = 'Dynamic'
        privateIPAddresses          = @()             # For static IPs, provide array: @('10.0.1.10', '10.0.1.11', '10.0.1.12')
        enableAcceleratedNetworking = $false
        deployNSG                   = $false
        nsgId                       = ''
        
        # OS Disk
        osDiskSizeGB                = 127
        osDiskType                  = 'Premium_LRS'
        
        # Data Disk
        dataDiskSizeGB              = 100
        dataDiskType                = 'Premium_LRS'
        
        # Security
        securityType                = 'Standard'
        secureBoot                  = $true
        vTPM                        = $true
        encryptionAtHost            = $false
        avsetId                     = ''
        integrityMonitoring         = $false
        
        # Licensing
        licenseType                 = 'None'
        
        # Tags
        tags                        = $tags
    }
}

$deployment = New-AzResourceGroupDeployment @deploymentParams

if ($deployment.ProvisioningState -eq "Succeeded") {
    Write-Host "`nDeployment succeeded!" -ForegroundColor Green
    Write-Host "`nDeployed VMs:" -ForegroundColor Cyan
    $deployment.Outputs.vmNames.Value | ForEach-Object { Write-Host "  - $_" -ForegroundColor White }
    Write-Host "`nPrivate IP Addresses:" -ForegroundColor Cyan
    for ($i = 0; $i -lt $deployment.Outputs.vmNames.Value.Count; $i++) {
        Write-Host "  - $($deployment.Outputs.vmNames.Value[$i]): $($deployment.Outputs.privateIPAddresses.Value[$i])" -ForegroundColor White
    }
} else {
    Write-Host "Deployment finished with state: $($deployment.ProvisioningState)" -ForegroundColor Yellow
}