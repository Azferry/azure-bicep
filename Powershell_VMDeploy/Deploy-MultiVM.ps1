<#
.SYNOPSIS
    Deploys multiple Azure Virtual Machines using PowerShell.

.DESCRIPTION
    This script provides a PowerShell-based alternative to the Bicep multi-VM deployment.
    It deploys N number of virtual machines with consistent configuration, supporting both
    Windows and Linux VMs with various security and networking options.

.PARAMETER ResourceGroupName
    Name of the resource group where VMs will be deployed.

.PARAMETER Location
    Azure region for deployment (e.g., 'eastus2').

.PARAMETER VMNamePrefix
    Base name prefix for VMs. VMs will be named as {VMNamePrefix}-1, {VMNamePrefix}-2, etc.

.PARAMETER VMCount
    Number of virtual machines to deploy (1-100).

.PARAMETER VMSize
    The size of the virtual machine (e.g., 'Standard_D2s_v3').

.PARAMETER OSType
    Operating system type: 'Windows' or 'Linux'.

.PARAMETER AdminUsername
    The admin username for the virtual machines.

.PARAMETER AdminPassword
    The admin password for the virtual machines (SecureString).

.PARAMETER ImageReferencePublisher
    Image publisher (e.g., 'RedHat', 'MicrosoftWindowsServer', 'Canonical').

.PARAMETER ImageReferenceOffer
    Image offer (e.g., 'RHEL', 'WindowsServer', '0001-com-ubuntu-server-jammy').

.PARAMETER ImageReferenceSku
    Image SKU (e.g., '8-lvm-gen2', '2022-datacenter-g2', '22_04-lts-gen2').

.PARAMETER ImageReferenceVersion
    Image version. Default: 'latest'.

.PARAMETER DiskEncryptionSetId
    Resource ID of the Disk Encryption Set for encrypting OS and data disks.

.PARAMETER SubnetId
    Full resource ID of the subnet where VM NICs will be attached.

.PARAMETER PrivateIPAllocationMethod
    IP allocation method: 'Dynamic' or 'Static'.

.PARAMETER PrivateIPAddresses
    Array of static private IP addresses (required when PrivateIPAllocationMethod is 'Static').

.PARAMETER EnableAcceleratedNetworking
    Enable accelerated networking on NICs.

.PARAMETER DeployNSG
    Deploy Network Security Group for each VM.

.PARAMETER NSGId
    Resource ID of an existing NSG to attach to NICs.

.PARAMETER OSDiskSizeGB
    OS disk size in GB.

.PARAMETER OSDiskType
    OS disk storage account type (e.g., 'Premium_LRS', 'StandardSSD_LRS').

.PARAMETER DataDiskSizeGB
    Data disk size in GB. Set to 0 to skip data disk creation.

.PARAMETER DataDiskType
    Data disk storage account type.

.PARAMETER SecurityType
    Security type: 'Standard', 'TrustedLaunch', or 'ConfidentialVM'.

.PARAMETER SecureBoot
    Enable Secure Boot (applies when SecurityType is 'TrustedLaunch').

.PARAMETER VTPM
    Enable vTPM (applies when SecurityType is 'TrustedLaunch').

.PARAMETER EncryptionAtHost
    Enable encryption at host for the virtual machines.

.PARAMETER AvailabilitySetId
    Resource ID of an availability set for the VMs.

.PARAMETER IntegrityMonitoring
    Enable integrity monitoring extension.

.PARAMETER LicenseType
    License type: 'Windows_Server' for Azure Hybrid Benefit, or 'None'.

.PARAMETER Tags
    Hashtable of tags to apply to all resources.

.EXAMPLE
    # Deploy 3 Linux VMs with dynamic IPs
    $params = @{
        ResourceGroupName = 'myRG'
        Location = 'eastus2'
        VMNamePrefix = 'linuxVM'
        VMCount = 3
        VMSize = 'Standard_D2s_v3'
        OSType = 'Linux'
        AdminUsername = 'azAdmin'
        AdminPassword = (ConvertTo-SecureString '' -AsPlainText -Force)
        SubnetId = '/subscriptions/{sub-id}/resourceGroups/{rg}/providers/Microsoft.Network/virtualNetworks/{vnet}/subnets/{subnet}'
    }
    .\Deploy-MultiVM.ps1 @params

.EXAMPLE
    # Deploy 2 Windows VMs with static IPs and Trusted Launch
    $params = @{
        ResourceGroupName = 'myRG'
        Location = 'eastus2'
        VMNamePrefix = 'winServer'
        VMCount = 2
        VMSize = 'Standard_D4s_v3'
        OSType = 'Windows'
        AdminUsername = 'azAdmin'
        AdminPassword = (ConvertTo-SecureString '' -AsPlainText -Force)
        ImageReferencePublisher = 'MicrosoftWindowsServer'
        ImageReferenceOffer = 'WindowsServer'
        ImageReferenceSku = '2022-datacenter-g2'
        SubnetId = '/subscriptions/{sub-id}/resourceGroups/{rg}/providers/Microsoft.Network/virtualNetworks/{vnet}/subnets/{subnet}'
        PrivateIPAllocationMethod = 'Static'
        PrivateIPAddresses = @('10.0.1.10', '10.0.1.11')
        SecurityType = 'TrustedLaunch'
        SecureBoot = $true
        VTPM = $true
        LicenseType = 'Windows_Server'
    }
    .\Deploy-MultiVM.ps1 @params

.NOTES
    Requires: Az.Compute, Az.Network PowerShell modules
   Version: 1.0
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ResourceGroupName,

    [Parameter(Mandatory = $false)]
    [string]$Location = 'eastus2',

    [Parameter(Mandatory = $false)]
    [string]$VMNamePrefix = 'myVM',

    [Parameter(Mandatory = $false)]
    [ValidateRange(1, 100)]
    [int]$VMCount = 2,

    [Parameter(Mandatory = $false)]
    [string]$VMSize = 'Standard_D2s_v3',

    [Parameter(Mandatory = $false)]
    [ValidateSet('Windows', 'Linux')]
    [string]$OSType = 'Linux',

    [Parameter(Mandatory = $false)]
    [string]$AdminUsername = 'azAdmin',

    [Parameter(Mandatory = $true)]
    [SecureString]$AdminPassword,

    # Image Reference
    [Parameter(Mandatory = $false)]
    [string]$ImageReferencePublisher = 'RedHat',

    [Parameter(Mandatory = $false)]
    [string]$ImageReferenceOffer = 'RHEL',

    [Parameter(Mandatory = $false)]
    [string]$ImageReferenceSku = '8-lvm-gen2',

    [Parameter(Mandatory = $false)]
    [string]$ImageReferenceVersion = 'latest',

    # Disk Encryption
    [Parameter(Mandatory = $false)]
    [string]$DiskEncryptionSetId = '',

    # Network
    [Parameter(Mandatory = $true)]
    [string]$SubnetId,

    [Parameter(Mandatory = $false)]
    [ValidateSet('Dynamic', 'Static')]
    [string]$PrivateIPAllocationMethod = 'Dynamic',

    [Parameter(Mandatory = $false)]
    [string[]]$PrivateIPAddresses = @(),

    [Parameter(Mandatory = $false)]
    [bool]$EnableAcceleratedNetworking = $false,

    [Parameter(Mandatory = $false)]
    [bool]$DeployNSG = $false,

    [Parameter(Mandatory = $false)]
    [string]$NSGId = '',

    # OS Disk
    [Parameter(Mandatory = $false)]
    [int]$OSDiskSizeGB = 127,

    [Parameter(Mandatory = $false)]
    [ValidateSet('Premium_LRS', 'Premium_ZRS', 'StandardSSD_LRS', 'StandardSSD_ZRS', 'Standard_LRS')]
    [string]$OSDiskType = 'Premium_LRS',

    # Data Disk
    [Parameter(Mandatory = $false)]
    [int]$DataDiskSizeGB = 100,

    [Parameter(Mandatory = $false)]
    [ValidateSet('Premium_LRS', 'Premium_ZRS', 'StandardSSD_LRS', 'StandardSSD_ZRS', 'Standard_LRS')]
    [string]$DataDiskType = 'Premium_LRS',

    # Security
    [Parameter(Mandatory = $false)]
    [ValidateSet('Standard', 'TrustedLaunch', 'ConfidentialVM')]
    [string]$SecurityType = 'Standard',

    [Parameter(Mandatory = $false)]
    [bool]$SecureBoot = $true,

    [Parameter(Mandatory = $false)]
    [bool]$VTPM = $true,

    [Parameter(Mandatory = $false)]
    [bool]$EncryptionAtHost = $false,

    [Parameter(Mandatory = $false)]
    [string]$AvailabilitySetId = '',

    [Parameter(Mandatory = $false)]
    [bool]$IntegrityMonitoring = $false,

    # Licensing
    [Parameter(Mandatory = $false)]
    [ValidateSet('Windows_Server', 'None')]
    [string]$LicenseType = 'None',

    # Tags
    [Parameter(Mandatory = $false)]
    [hashtable]$Tags = @{}
)

# Validation and Initialization
Write-Host "══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  Multi-VM Deployment Script" -ForegroundColor Cyan
Write-Host "══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# Validate Static IP configuration
if ($PrivateIPAllocationMethod -eq 'Static') {
    if ($PrivateIPAddresses.Count -lt $VMCount) {
        Write-Host "ERROR: When using Static IP allocation, you must provide at least $VMCount IP addresses." -ForegroundColor Red
        Write-Host "       Current count: $($PrivateIPAddresses.Count)" -ForegroundColor Red
        exit 1
    }
}

# Check if resource group exists
Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Checking resource group..." -ForegroundColor Yellow
$rg = Get-AzResourceGroup -Name $ResourceGroupName -ErrorAction SilentlyContinue
if (-not $rg) {
    Write-Host "ERROR: Resource group '$ResourceGroupName' does not exist." -ForegroundColor Red
    Write-Host "       Please create it first or provide an existing resource group name." -ForegroundColor Red
    exit 1
}
Write-Host "  ✓ Resource group '$ResourceGroupName' found" -ForegroundColor Green

# Extract subnet object
Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Validating subnet..." -ForegroundColor Yellow
try {
    $subnet = Get-AzResource -ResourceId $SubnetId -ErrorAction Stop
    Write-Host "  ✓ Subnet validated" -ForegroundColor Green
} catch {
    Write-Host "ERROR: Unable to validate subnet with ID: $SubnetId" -ForegroundColor Red
    Write-Host "       $_" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Deployment Configuration:" -ForegroundColor Cyan
Write-Host "  Resource Group: $ResourceGroupName" -ForegroundColor White
Write-Host "  Location: $Location" -ForegroundColor White
Write-Host "  VM Count: $VMCount" -ForegroundColor White
Write-Host "  VM Name Pattern: $VMNamePrefix-{1..$VMCount}" -ForegroundColor White
Write-Host "  VM Size: $VMSize" -ForegroundColor White
Write-Host "  OS Type: $OSType" -ForegroundColor White
Write-Host "  Image: $ImageReferencePublisher/$ImageReferenceOffer/$ImageReferenceSku" -ForegroundColor White
Write-Host "  IP Allocation: $PrivateIPAllocationMethod" -ForegroundColor White
Write-Host "  Security Type: $SecurityType" -ForegroundColor White
Write-Host ""

# Deployment Variables
$deployedVMs = @()
$deployedNICs = @()
$deployedNSGs = @()
$vmPrivateIPs = @()
$deploymentStartTime = Get-Date

# Credentials
$cred = New-Object System.Management.Automation.PSCredential($AdminUsername, $AdminPassword)

# VM Deployment Loop
Write-Host "Starting VM deployments..." -ForegroundColor Cyan
Write-Host ""

for ($i = 1; $i -le $VMCount; $i++) {
    $vmName = "$VMNamePrefix$i"
    $nicName = "$vmName-nic"
    $osDiskName = "$vmName-osdisk"
    $dataDiskName = "$vmName-datadisk-0"
    $nsgName = "$vmName-nsg"

    Write-Host "─────────────────────────────────────────────────────────────" -ForegroundColor DarkGray
    Write-Host "VM $i of $VMCount : $vmName" -ForegroundColor Cyan
    Write-Host "─────────────────────────────────────────────────────────────" -ForegroundColor DarkGray

    try {
        # 1. Create Network Security Group (if requested)
        $nsg = $null
        if ($DeployNSG -and [string]::IsNullOrEmpty($NSGId)) {
            Write-Host "  [$(Get-Date -Format 'HH:mm:ss')] Creating NSG: $nsgName..." -ForegroundColor Yellow
            $nsg = New-AzNetworkSecurityGroup -Name $nsgName -ResourceGroupName $ResourceGroupName -Location $Location -Tag $Tags -Force
            $deployedNSGs += $nsg
            Write-Host "  ✓ NSG created" -ForegroundColor Green
        } elseif ($DeployNSG -and -not [string]::IsNullOrEmpty($NSGId)) {
            Write-Host "  [$(Get-Date -Format 'HH:mm:ss')] Using existing NSG..." -ForegroundColor Yellow
            $nsg = Get-AzResource -ResourceId $NSGId | Get-AzNetworkSecurityGroup
            Write-Host "  ✓ NSG referenced" -ForegroundColor Green
        }

        # 2. Create Network Interface
        Write-Host "  [$(Get-Date -Format 'HH:mm:ss')] Creating NIC: $nicName..." -ForegroundColor Yellow
        
        $ipConfigParams = @{
            Name = 'ipconfig1'
            SubnetId = $SubnetId
            PrivateIpAddressVersion = 'IPv4'
        }

        if ($PrivateIPAllocationMethod -eq 'Static') {
            $ipConfigParams.PrivateIpAddress = $PrivateIPAddresses[$i - 1]
        }

        $ipConfig = New-AzNetworkInterfaceIpConfig @ipConfigParams

        $nicParams = @{
            Name = $nicName
            ResourceGroupName = $ResourceGroupName
            Location = $Location
            IpConfiguration = $ipConfig
            Tag = $Tags
            Force = $true
        }

        if ($EnableAcceleratedNetworking) {
            $nicParams.EnableAcceleratedNetworking = $true
        }

        if ($DeployNSG -and $nsg) {
            $nicParams.NetworkSecurityGroupId = $nsg.Id
        }

        $nic = New-AzNetworkInterface @nicParams
        $deployedNICs += $nic
        
        $assignedIP = $nic.IpConfigurations[0].PrivateIpAddress
        $vmPrivateIPs += $assignedIP
        
        Write-Host "  ✓ NIC created (IP: $assignedIP)" -ForegroundColor Green

        # 3. Configure VM
        Write-Host "  [$(Get-Date -Format 'HH:mm:ss')] Configuring VM object..." -ForegroundColor Yellow

        $vmConfig = New-AzVMConfig -VMName $vmName -VMSize $VMSize

        if (-not [string]::IsNullOrEmpty($AvailabilitySetId)) {
            $vmConfig = Set-AzVMAvailabilitySet -VM $vmConfig -Id $AvailabilitySetId
        }

        if ($OSType -eq 'Windows') {
            $vmConfig = Set-AzVMOperatingSystem -VM $vmConfig -Windows -ComputerName $vmName -Credential $cred -ProvisionVMAgent -EnableAutoUpdate
        } else {
            $vmConfig = Set-AzVMOperatingSystem -VM $vmConfig -Linux -ComputerName $vmName -Credential $cred -DisablePasswordAuthentication:$false
        }

        $vmConfig = Set-AzVMSourceImage -VM $vmConfig -PublisherName $ImageReferencePublisher -Offer $ImageReferenceOffer -Skus $ImageReferenceSku -Version $ImageReferenceVersion
        $vmConfig = Add-AzVMNetworkInterface -VM $vmConfig -Id $nic.Id -DeleteOption 'Delete'

        $osDiskParams = @{
            VM = $vmConfig
            Name = $osDiskName
            CreateOption = 'FromImage'
            DiskSizeInGB = $OSDiskSizeGB
            StorageAccountType = $OSDiskType
            DeleteOption = 'Delete'
        }

        if ($OSType -eq 'Windows') {
            $osDiskParams.Windows = $true
        } else {
            $osDiskParams.Linux = $true
        }

        if (-not [string]::IsNullOrEmpty($DiskEncryptionSetId)) {
            $osDiskParams.DiskEncryptionSetId = $DiskEncryptionSetId
        }

        $vmConfig = Set-AzVMOSDisk @osDiskParams

        if ($DataDiskSizeGB -gt 0) {
            $dataDiskParams = @{
                VM = $vmConfig
                Name = $dataDiskName
                DiskSizeInGB = $DataDiskSizeGB
                Lun = 0
                CreateOption = 'Empty'
                StorageAccountType = $DataDiskType
                DeleteOption = 'Delete'
            }

            if (-not [string]::IsNullOrEmpty($DiskEncryptionSetId)) {
                $dataDiskParams.DiskEncryptionSetId = $DiskEncryptionSetId
            }

            $vmConfig = Add-AzVMDataDisk @dataDiskParams
        }

        if ($SecurityType -eq 'TrustedLaunch') {
            $vmConfig = Set-AzVMSecurityProfile -VM $vmConfig -SecurityType $SecurityType
            $vmConfig = Set-AzVMUefi -VM $vmConfig -EnableSecureBoot $SecureBoot -EnableVtpm $VTPM
        }

        if ($EncryptionAtHost) {
            $vmConfig.SecurityProfile.EncryptionAtHost = $true
        }

        $vmConfig = Set-AzVMBootDiagnostic -VM $vmConfig -Enable

        if ($LicenseType -ne 'None') {
            $vmConfig.LicenseType = $LicenseType
        }

        Write-Host "  ✓ VM configured" -ForegroundColor Green

        # 4. Create Virtual Machine
        Write-Host "  [$(Get-Date -Format 'HH:mm:ss')] Creating VM: $vmName..." -ForegroundColor Yellow
        
        $vm = New-AzVM -ResourceGroupName $ResourceGroupName -Location $Location -VM $vmConfig -Tag $Tags -ErrorAction Stop

        $deployedVMs += $vm
        Write-Host "  ✓ VM created successfully" -ForegroundColor Green

        # 5. Configure Extensions (if needed)
        if ($IntegrityMonitoring -and $SecurityType -eq 'TrustedLaunch') {
            Write-Host "  [$(Get-Date -Format 'HH:mm:ss')] Installing integrity monitoring extension..." -ForegroundColor Yellow
            
            $extensionParams = @{
                ResourceGroupName = $ResourceGroupName
                VMName = $vmName
                Name = 'GuestAttestation'
                Publisher = 'Microsoft.Azure.Security.WindowsAttestation'
                Type = 'GuestAttestation'
                TypeHandlerVersion = '1.0'
                EnableAutomaticUpgrade = $true
                Location = $Location
                ErrorAction = 'Stop'
            }

            Set-AzVMExtension @extensionParams | Out-Null
            Write-Host "  ✓ Extension installed" -ForegroundColor Green
        }

        Write-Host "  ✓ VM deployment completed: $vmName" -ForegroundColor Green
        Write-Host ""

    } catch {
        Write-Host "  ✗ ERROR deploying VM: $vmName" -ForegroundColor Red
        Write-Host "  Error details: $_" -ForegroundColor Red
        Write-Host ""
    }
}

# Deployment Summary
$deploymentEndTime = Get-Date
$deploymentDuration = $deploymentEndTime - $deploymentStartTime

Write-Host "══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  Deployment Summary" -ForegroundColor Cyan
Write-Host "══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "Total Duration: $($deploymentDuration.ToString('hh\:mm\:ss'))" -ForegroundColor White
Write-Host ""
Write-Host "Deployed Resources:" -ForegroundColor Yellow
Write-Host "  Virtual Machines: $($deployedVMs.Count) / $VMCount" -ForegroundColor White
Write-Host "  Network Interfaces: $($deployedNICs.Count)" -ForegroundColor White
if ($DeployNSG) {
    Write-Host "  Network Security Groups: $($deployedNSGs.Count)" -ForegroundColor White
}
Write-Host ""

if ($deployedVMs.Count -gt 0) {
    Write-Host "Virtual Machine Details:" -ForegroundColor Yellow
    for ($i = 0; $i -lt $deployedVMs.Count; $i++) {
        $vm = $deployedVMs[$i]
        Write-Host "  [$($i + 1)] $($vm.Name)" -ForegroundColor Cyan
        Write-Host "      Resource ID: $($vm.Id)" -ForegroundColor Gray
        Write-Host "      Private IP:  $($vmPrivateIPs[$i])" -ForegroundColor Gray
        Write-Host "      Size:        $($vm.HardwareProfile.VmSize)" -ForegroundColor Gray
        Write-Host "      Status:      Deployed" -ForegroundColor Green
        Write-Host ""
    }
}

if ($deployedVMs.Count -eq $VMCount) {
    Write-Host "✓ All VMs deployed successfully!" -ForegroundColor Green
} else {
    Write-Host "⚠ Warning: $($VMCount - $deployedVMs.Count) VM(s) failed to deploy" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "══════════════════════════════════════════════════════════════" -ForegroundColor Cyan

# Return deployment results
return [PSCustomObject]@{
    DeployedVMs = $deployedVMs
    DeployedNICs = $deployedNICs
    DeployedNSGs = $deployedNSGs
    PrivateIPAddresses = $vmPrivateIPs
    Duration = $deploymentDuration
    SuccessCount = $deployedVMs.Count
    RequestedCount = $VMCount
}