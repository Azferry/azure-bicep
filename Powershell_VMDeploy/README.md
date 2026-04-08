# Multi-VM Deployment with PowerShell

This folder contains PowerShell scripts for deploying multiple Azure Virtual Machines as a backup/alternative to the Bicep multi-VM deployment solution.

## Overview

The PowerShell-based deployment provides the same functionality as the Bicep version but uses native Azure PowerShell cmdlets, making it suitable for scenarios where:

- PowerShell is the preferred scripting language
- Bicep is not available or cannot be used
- Additional custom logic or integration is needed
- Onsite backup deployment capability is required

## File Structure

```
Powershell_VMDeploy/
├── Deploy-MultiVM.ps1      # Main deployment script
├── Example-Config.ps1      # Configuration examples and helpers
└── README.md               # This file
```

## Prerequisites

### Required Modules

Install the required Azure PowerShell modules:

```powershell
Install-Module -Name Az.Compute -Force -AllowClobber
Install-Module -Name Az.Network -Force -AllowClobber
Install-Module -Name Az.Resources -Force -AllowClobber
```

### Azure Authentication

Authenticate to Azure before running the deployment:

```powershell
# For Azure Commercial
Connect-AzAccount

# For Azure Government
Connect-AzAccount -Environment AzureUSGovernment

# Select the correct subscription
Set-AzContext -SubscriptionId "your-subscription-id"
```

### Resource Group

Ensure the target resource group exists:

```powershell
# Create if needed
New-AzResourceGroup -Name 'myResourceGroup' -Location 'eastus2'
```

## Quick Start

### Basic Deployment (3 Linux VMs)

```powershell
$params = @{
    ResourceGroupName = 'myResourceGroup'
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
```

### Advanced Deployment (Windows with Trusted Launch)

```powershell
$params = @{
    ResourceGroupName = 'myResourceGroup'
    Location = 'eastus2'
    VMNamePrefix = 'winServer'
    VMCount = 2
    VMSize = 'Standard_D4s_v3'
    OSType = 'Windows'
    AdminUsername = 'azAdmin'
    AdminPassword = (ConvertTo-SecureString '' -AsPlainText -Force)
    
    # Windows Server 2022
    ImageReferencePublisher = 'MicrosoftWindowsServer'
    ImageReferenceOffer = 'WindowsServer'
    ImageReferenceSku = '2022-datacenter-g2'
    
    # Network
    SubnetId = '/subscriptions/{sub-id}/resourceGroups/{rg}/providers/Microsoft.Network/virtualNetworks/{vnet}/subnets/{subnet}'
    PrivateIPAllocationMethod = 'Static'
    PrivateIPAddresses = @('10.0.1.10', '10.0.1.11')
    
    # Security
    SecurityType = 'TrustedLaunch'
    SecureBoot = $true
    VTPM = $true
    IntegrityMonitoring = $true
    LicenseType = 'Windows_Server'
    
    Tags = @{ Environment = 'Production'; Project = 'MyApp' }
}

.\Deploy-MultiVM.ps1 @params
```

## Parameters

### Required Parameters

| Parameter | Description |
|-----------|-------------|
| `ResourceGroupName` | Name of the resource group for deployment |
| `SubnetId` | Full resource ID of the subnet for VM NICs |
| `AdminPassword` | SecureString password for VM admin account |

### Optional Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| `Location` | `eastus2` | Azure region |
| `VMNamePrefix` | `myVM` | Base name for VMs |
| `VMCount` | `2` | Number of VMs (1-100) |
| `VMSize` | `Standard_D2s_v3` | VM size |
| `OSType` | `Linux` | `Windows` or `Linux` |
| `AdminUsername` | `azAdmin` | Admin username |

#### Image Reference

| Parameter | Default | Description |
|-----------|---------|-------------|
| `ImageReferencePublisher` | `RedHat` | Image publisher |
| `ImageReferenceOffer` | `RHEL` | Image offer |
| `ImageReferenceSku` | `8-lvm-gen2` | Image SKU |
| `ImageReferenceVersion` | `latest` | Image version |

#### Network Configuration

| Parameter | Default | Description |
|-----------|---------|-------------|
| `PrivateIPAllocationMethod` | `Dynamic` | `Dynamic` or `Static` |
| `PrivateIPAddresses` | `@()` | Array of static IPs (when using Static) |
| `EnableAcceleratedNetworking` | `$false` | Enable accelerated networking |
| `DeployNSG` | `$false` | Deploy NSG per VM |
| `NSGId` | `''` | Existing NSG resource ID |

#### Disk Configuration

| Parameter | Default | Description |
|-----------|---------|-------------|
| `OSDiskSizeGB` | `127` | OS disk size in GB |
| `OSDiskType` | `Premium_LRS` | OS disk storage type |
| `DataDiskSizeGB` | `100` | Data disk size (0 = no data disk) |
| `DataDiskType` | `Premium_LRS` | Data disk storage type |
| `DiskEncryptionSetId` | `''` | Disk Encryption Set resource ID |

#### Security Settings

| Parameter | Default | Description |
|-----------|---------|-------------|
| `SecurityType` | `Standard` | `Standard`, `TrustedLaunch`, or `ConfidentialVM` |
| `SecureBoot` | `$true` | Enable Secure Boot (TrustedLaunch) |
| `VTPM` | `$true` | Enable vTPM (TrustedLaunch) |
| `EncryptionAtHost` | `$false` | Enable encryption at host |
| `IntegrityMonitoring` | `$false` | Install integrity monitoring extension |
| `AvailabilitySetId` | `''` | Availability Set resource ID |

#### Other Settings

| Parameter | Default | Description |
|-----------|---------|-------------|
| `LicenseType` | `None` | `Windows_Server` or `None` |
| `Tags` | `@{}` | Hashtable of tags |

## Usage Examples

See `Example-Config.ps1` for detailed configuration examples including:

1. **Linux VMs with Dynamic IPs** - Basic deployment
2. **Windows VMs with Static IPs** - Advanced networking
3. **Ubuntu VMs with Disk Encryption** - Security-focused
4. **VMs with Availability Set** - High availability

## Common Scenarios

### Deploy to Existing Infrastructure

```powershell
$params = @{
    ResourceGroupName = 'existing-rg'
    VMNamePrefix = 'appVM'
    VMCount = 5
    AdminPassword = (ConvertTo-SecureString '' -AsPlainText -Force)
    SubnetId = '/subscriptions/.../subnets/app-subnet'
    
    # Use existing NSG
    DeployNSG = $true
    NSGId = '/subscriptions/.../networkSecurityGroups/app-nsg'
    
    # Use existing Availability Set
    AvailabilitySetId = '/subscriptions/.../availabilitySets/app-avset'
}

.\Deploy-MultiVM.ps1 @params
```

### Deploy with Disk Encryption

```powershell
$params = @{
    ResourceGroupName = 'secure-rg'
    VMNamePrefix = 'secureVM'
    VMCount = 3
    AdminPassword = (ConvertTo-SecureString '' -AsPlainText -Force)
    SubnetId = '/subscriptions/.../subnets/secure-subnet'
    
    # Disk Encryption Set
    DiskEncryptionSetId = '/subscriptions/.../diskEncryptionSets/my-des'
    
    # Additional encryption
    EncryptionAtHost = $true
    SecurityType = 'TrustedLaunch'
}

.\Deploy-MultiVM.ps1 @params
```

### Static IP Allocation

```powershell
$params = @{
    ResourceGroupName = 'network-rg'
    VMNamePrefix = 'staticVM'
    VMCount = 4
    AdminPassword = (ConvertTo-SecureString '' -AsPlainText -Force)
    SubnetId = '/subscriptions/.../subnets/my-subnet'
    
    # Static IPs
    PrivateIPAllocationMethod = 'Static'
    PrivateIPAddresses = @(
        '10.0.1.10'
        '10.0.1.11'
        '10.0.1.12'
        '10.0.1.13'
    )
}

.\Deploy-MultiVM.ps1 @params
```

## Common Image References

### Linux Operating Systems

| OS | Publisher | Offer | SKU |
|----|-----------|-------|-----|
| **Red Hat Enterprise Linux 8** | `RedHat` | `RHEL` | `8-lvm-gen2` |
| **Red Hat Enterprise Linux 9** | `RedHat` | `RHEL` | `9-lvm-gen2` |
| **Ubuntu 22.04 LTS** | `Canonical` | `0001-com-ubuntu-server-jammy` | `22_04-lts-gen2` |
| **Ubuntu 20.04 LTS** | `Canonical` | `0001-com-ubuntu-server-focal` | `20_04-lts-gen2` |
| **CentOS 7.9** | `OpenLogic` | `CentOS` | `7_9-gen2` |

### Windows Operating Systems

| OS | Publisher | Offer | SKU |
|----|-----------|-------|-----|
| **Windows Server 2022** | `MicrosoftWindowsServer` | `WindowsServer` | `2022-datacenter-g2` |
| **Windows Server 2019** | `MicrosoftWindowsServer` | `WindowsServer` | `2019-datacenter-gensecond` |
| **Windows 11 Pro** | `MicrosoftWindowsDesktop` | `Windows-11` | `win11-22h2-pro` |
| **Windows 10 Enterprise** | `MicrosoftWindowsDesktop` | `Windows-10` | `win10-22h2-ent-g2` |

## Output and Results

The script returns a custom PowerShell object with deployment results:

```powershell
$result = .\Deploy-MultiVM.ps1 @params

# Access deployment details
$result.DeployedVMs          # Array of VM objects
$result.DeployedNICs         # Array of NIC objects
$result.DeployedNSGs         # Array of NSG objects (if deployed)
$result.PrivateIPAddresses   # Array of assigned IPs
$result.Duration             # Total deployment time
$result.SuccessCount         # Number of successful deployments
$result.RequestedCount       # Number of VMs requested

# Example: Get VM details
foreach ($vm in $result.DeployedVMs) {
    Write-Host "$($vm.Name): $($vm.Id)"
}

# Example: Export IPs to file
$result.PrivateIPAddresses | Out-File -FilePath "deployed-ips.txt"
```

## Comparison with Bicep Deployment

| Feature | Bicep | PowerShell |
|---------|-------|------------|
| **Deployment Method** | Declarative | Imperative |
| **Module Support** | Yes | N/A (script-based) |
| **Error Handling** | ARM-level | Script-level |
| **Flexibility** | Template-based | Full scripting |
| **Real-time Output** | Limited | Detailed console output |
| **Custom Logic** | Limited | Full PowerShell capabilities |
| **Integration** | Azure-native | Any PowerShell workflow |

## Troubleshooting

### Issue: "Resource group not found"

**Solution**: Create the resource group first or verify the name:

```powershell
New-AzResourceGroup -Name 'myResourceGroup' -Location 'eastus2'
```

### Issue: "Subnet validation failed"

**Solution**: Verify the subnet resource ID format and ensure it exists:

```powershell
Get-AzVirtualNetworkSubnetConfig -ResourceId '/subscriptions/...'
```

### Issue: "Not enough static IP addresses"

**Solution**: When using Static IP allocation, provide an IP for each VM:

```powershell
PrivateIPAddresses = @('10.0.1.10', '10.0.1.11', '10.0.1.12')  # For 3 VMs
```

### Issue: "Quota exceeded"

**Solution**: Check your subscription quotas:

```powershell
Get-AzVMUsage -Location 'eastus2' | Where-Object {$_.CurrentValue -gt 0}
```

### Issue: Individual VM deployment fails

**Behavior**: The script continues with remaining VMs by default.

**To stop on first error**: Uncomment the `# throw` line in the catch block (line ~485).

## Best Practices

1. **Use SecureString for passwords**: Always use `ConvertTo-SecureString` for passwords
2. **Tag your resources**: Apply consistent tagging for cost tracking and organization
3. **Test with small deployments**: Start with `VMCount = 1` to validate configuration
4. **Use Static IPs carefully**: Ensure IPs are available in the subnet
5. **Enable Trusted Launch**: For enhanced security (when supported by VM size)
6. **Monitor deployments**: Watch the console output for any warnings or errors
7. **Document configurations**: Keep your parameter sets in version control

## Advanced Usage

### Run Parallel Deployments

PowerShell jobs can be used for parallel resource group deployments:

```powershell
$job1 = Start-Job -ScriptBlock {
    .\Deploy-MultiVM.ps1 -ResourceGroupName 'rg1' -VMCount 5 @commonParams
}

$job2 = Start-Job -ScriptBlock {
    .\Deploy-MultiVM.ps1 -ResourceGroupName 'rg2' -VMCount 5 @commonParams
}

Wait-Job $job1, $job2
Receive-Job $job1, $job2
```

### Integration with CI/CD

The script can be integrated into Azure DevOps or GitHub Actions:

```yaml
# Azure DevOps example
- task: AzurePowerShell@5
  inputs:
    azureSubscription: 'MyAzureConnection'
    ScriptType: 'FilePath'
    ScriptPath: '$(System.DefaultWorkingDirectory)/Deploy-MultiVM.ps1'
    ScriptArguments: '-ResourceGroupName "$(ResourceGroup)" -VMCount 3 ...'
    azurePowerShellVersion: 'LatestVersion'
```

## Notes

- VM names are generated as `{VMNamePrefix}{index}` where index starts at 1
- Maximum of 100 VMs per deployment (adjustable in script)
- All VMs are deployed to the same subnet
- Boot diagnostics are enabled by default
- Delete options are set to `Delete` for NICs and disks (cleaned up with VM deletion)

## Support

For issues or questions:
- Review the inline script documentation (`Get-Help .\Deploy-MultiVM.ps1 -Full`)
- Check Azure PowerShell documentation
- Verify Azure subscription quotas and limits

## Version History

- **v1.0**: Initial release - PowerShell-based multi-VM deployment matching Bicep functionality