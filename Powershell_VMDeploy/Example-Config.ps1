##############################################################################
# Multi-VM Deployment Configuration Example
# 
# This file demonstrates how to configure and execute the Deploy-MultiVM.ps1
# script with various parameter combinations.
##############################################################################

# Import required modules
Import-Module Az.Compute
Import-Module Az.Network

# ============================================================================
# EXAMPLE 1: Deploy 3 Linux VMs with Dynamic IPs
# ============================================================================

$params1 = @{
    ResourceGroupName = 'myResourceGroup'
    Location = 'eastus2'
    VMNamePrefix = 'linuxVM'
    VMCount = 3
    VMSize = 'Standard_D2s_v3'
    OSType = 'Linux'
    AdminUsername = 'azAdmin'
    AdminPassword = (ConvertTo-SecureString '' -AsPlainText -Force)
    
    # Image Reference (Red Hat Enterprise Linux 8)
    ImageReferencePublisher = 'RedHat'
    ImageReferenceOffer = 'RHEL'
    ImageReferenceSku = '8-lvm-gen2'
    ImageReferenceVersion = 'latest'
    
    # Network Configuration
    SubnetId = '/subscriptions/{subscription-id}/resourceGroups/{rg-name}/providers/Microsoft.Network/virtualNetworks/{vnet-name}/subnets/{subnet-name}'
    PrivateIPAllocationMethod = 'Dynamic'
    EnableAcceleratedNetworking = $false
    
    # Disk Configuration
    OSDiskSizeGB = 127
    OSDiskType = 'Premium_LRS'
    DataDiskSizeGB = 100
    DataDiskType = 'Premium_LRS'
    
    # Security Settings
    SecurityType = 'Standard'
    
    # Tags
    Tags = @{
        Environment = 'Development'
        Project = 'TestProject'
        Owner = 'DevTeam'
    }
}

# Execute deployment
# .\Deploy-MultiVM.ps1 @params1

# ============================================================================
# EXAMPLE 2: Deploy 2 Windows Server VMs with Static IPs and Trusted Launch
# ============================================================================

$params2 = @{
    ResourceGroupName = 'myResourceGroup'
    Location = 'eastus2'
    VMNamePrefix = 'winServer'
    VMCount = 2
    VMSize = 'Standard_D4s_v3'
    OSType = 'Windows'
    AdminUsername = 'azAdmin'
    AdminPassword = (ConvertTo-SecureString '' -AsPlainText -Force)
    
    # Image Reference (Windows Server 2022)
    ImageReferencePublisher = 'MicrosoftWindowsServer'
    ImageReferenceOffer = 'WindowsServer'
    ImageReferenceSku = '2022-datacenter-g2'
    ImageReferenceVersion = 'latest'
    
    # Network Configuration with Static IPs
    SubnetId = '/subscriptions/{subscription-id}/resourceGroups/{rg-name}/providers/Microsoft.Network/virtualNetworks/{vnet-name}/subnets/{subnet-name}'
    PrivateIPAllocationMethod = 'Static'
    PrivateIPAddresses = @('10.0.1.10', '10.0.1.11')
    EnableAcceleratedNetworking = $true
    
    # Disk Configuration
    OSDiskSizeGB = 127
    OSDiskType = 'Premium_LRS'
    DataDiskSizeGB = 512
    DataDiskType = 'Premium_LRS'
    
    # Security Settings (Trusted Launch)
    SecurityType = 'TrustedLaunch'
    SecureBoot = $true
    VTPM = $true
    IntegrityMonitoring = $true
    
    # Licensing (Azure Hybrid Benefit)
    LicenseType = 'Windows_Server'
    
    # Tags
    Tags = @{
        Environment = 'Production'
        Project = 'CriticalApp'
        CostCenter = 'IT-001'
    }
}

# Execute deployment
# .\Deploy-MultiVM.ps1 @params2

# ============================================================================
# EXAMPLE 3: Deploy 5 Ubuntu VMs with Disk Encryption Set
# ============================================================================

$params3 = @{
    ResourceGroupName = 'myResourceGroup'
    Location = 'eastus2'
    VMNamePrefix = 'ubuntuVM'
    VMCount = 5
    VMSize = 'Standard_D2s_v3'
    OSType = 'Linux'
    AdminUsername = 'azAdmin'
    AdminPassword = (ConvertTo-SecureString '' -AsPlainText -Force)
    
    # Image Reference (Ubuntu 22.04 LTS)
    ImageReferencePublisher = 'Canonical'
    ImageReferenceOffer = '0001-com-ubuntu-server-jammy'
    ImageReferenceSku = '22_04-lts-gen2'
    ImageReferenceVersion = 'latest'
    
    # Disk Encryption Set
    DiskEncryptionSetId = '/subscriptions/{subscription-id}/resourceGroups/{rg-name}/providers/Microsoft.Compute/diskEncryptionSets/{des-name}'
    
    # Network Configuration
    SubnetId = '/subscriptions/{subscription-id}/resourceGroups/{rg-name}/providers/Microsoft.Network/virtualNetworks/{vnet-name}/subnets/{subnet-name}'
    PrivateIPAllocationMethod = 'Dynamic'
    DeployNSG = $true
    
    # Disk Configuration
    OSDiskSizeGB = 127
    OSDiskType = 'StandardSSD_LRS'
    DataDiskSizeGB = 0  # No data disk
    
    # Security Settings
    SecurityType = 'Standard'
    EncryptionAtHost = $true
    
    # Tags
    Tags = @{
        Environment = 'Testing'
        Application = 'WebServers'
    }
}

# Execute deployment
# .\Deploy-MultiVM.ps1 @params3

# ============================================================================
# EXAMPLE 4: Deploy VMs with Existing NSG and Availability Set
# ============================================================================

$params4 = @{
    ResourceGroupName = 'myResourceGroup'
    Location = 'eastus2'
    VMNamePrefix = 'appServer'
    VMCount = 3
    VMSize = 'Standard_D8s_v3'
    OSType = 'Linux'
    AdminUsername = 'azAdmin'
    AdminPassword = (ConvertTo-SecureString '' -AsPlainText -Force)
    
    # Image Reference (Red Hat Enterprise Linux)
    ImageReferencePublisher = 'RedHat'
    ImageReferenceOffer = 'RHEL'
    ImageReferenceSku = '8-lvm-gen2'
    ImageReferenceVersion = 'latest'
    
    # Network Configuration with existing NSG
    SubnetId = '/subscriptions/{subscription-id}/resourceGroups/{rg-name}/providers/Microsoft.Network/virtualNetworks/{vnet-name}/subnets/{subnet-name}'
    PrivateIPAllocationMethod = 'Dynamic'
    DeployNSG = $true
    NSGId = '/subscriptions/{subscription-id}/resourceGroups/{rg-name}/providers/Microsoft.Network/networkSecurityGroups/{nsg-name}'
    EnableAcceleratedNetworking = $true
    
    # Availability Set
    AvailabilitySetId = '/subscriptions/{subscription-id}/resourceGroups/{rg-name}/providers/Microsoft.Compute/availabilitySets/{avset-name}'
    
    # Disk Configuration
    OSDiskSizeGB = 127
    OSDiskType = 'Premium_LRS'
    DataDiskSizeGB = 1024
    DataDiskType = 'Premium_LRS'
    
    # Security Settings
    SecurityType = 'Standard'
    
    # Tags
    Tags = @{
        Environment = 'Production'
        Tier = 'Application'
        HA = 'Enabled'
    }
}

# Execute deployment
# .\Deploy-MultiVM.ps1 @params4

# ============================================================================
# HELPER: Create Resource Group (if needed)
# ============================================================================

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

# Example: Create resource group
# New-VMResourceGroup -Name 'myResourceGroup' -Location 'eastus2' -Tags @{ Project = 'MultiVM' }

# ============================================================================
# HELPER: Validate Deployment Parameters
# ============================================================================

function Test-VMDeploymentParams {
    param(
        [hashtable]$Parameters
    )
    
    Write-Host "Validating deployment parameters..." -ForegroundColor Cyan
    
    $validationPassed = $true
    
    # Check required parameters
    if (-not $Parameters.ContainsKey('ResourceGroupName')) {
        Write-Host "  ✗ ResourceGroupName is required" -ForegroundColor Red
        $validationPassed = $false
    }
    
    if (-not $Parameters.ContainsKey('SubnetId')) {
        Write-Host "  ✗ SubnetId is required" -ForegroundColor Red
        $validationPassed = $false
    }
    
    if (-not $Parameters.ContainsKey('AdminPassword')) {
        Write-Host "  ✗ AdminPassword is required" -ForegroundColor Red
        $validationPassed = $false
    }
    
    # Validate Static IP configuration
    if ($Parameters.PrivateIPAllocationMethod -eq 'Static') {
        if ($Parameters.PrivateIPAddresses.Count -lt $Parameters.VMCount) {
            Write-Host "  ✗ Not enough static IP addresses for VM count" -ForegroundColor Red
            $validationPassed = $false
        }
    }
    
    if ($validationPassed) {
        Write-Host "  ✓ All parameters validated" -ForegroundColor Green
    }
    
    return $validationPassed
}

# Example: Validate parameters before deployment
# if (Test-VMDeploymentParams -Parameters $params1) {
#     .\Deploy-MultiVM.ps1 @params1
# }