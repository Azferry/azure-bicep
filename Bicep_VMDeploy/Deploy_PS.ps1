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


$location       = "eastus2" # Azure region for deployment
$resourceGroupName = 'biceptesting-rg'
$tags           = @{
    Environment = "Test"
    Project     = "BicepTest"
}
$deploymentName = "BicepTest-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
$templateFile   = ".\main.bicep"

New-VMResourceGroup -Name $resourceGroupName -Location $location -Tags $tags

Write-Host "Logging in to Azure..." -ForegroundColor Cyan
Connect-AzAccount

Write-Host "Starting deployment: $deploymentName" -ForegroundColor Cyan

$deploymentParams = @{
    Name                  = $deploymentName
    Location              = $location
    ResourceGroupName     = $resourceGroupName
    TemplateFile          = $templateFile
    TemplateParameterObject = @{
        # Basic Configuration
        location                    = $location
        vmName                      = 'myVM'
        vmSize                      = 'Standard_D2s_v3'
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
        privateIPAddress            = ''
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
    Write-Host "Deployment succeeded." -ForegroundColor Green
} else {
    Write-Host "Deployment finished with state: $($deployment.ProvisioningState)" -ForegroundColor Yellow
}
