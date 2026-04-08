# Multi VM Deployment with Bicep

This folder contains Bicep templates for deploying multiple virtual machines using a modular approach with looping capabilities.

## Overview

The solution uses a **module-based architecture** that allows you to deploy N number of virtual machines by simply specifying a count parameter. Each VM is deployed using a reusable module, making the deployment scalable and maintainable.

## File Structure

```
Bicep_VMDeploy_Multi/
├── main.bicep              # Main template with loop logic
├── modules/
│   └── vm.bicep           # Reusable VM module
├── Deploy_PS.ps1          # PowerShell deployment script
└── readme.md              # This file
```

## Key Features

- **Scalable Deployment**: Deploy 1-100 VMs using a single `vmCount` parameter
- **Modular Design**: Reusable VM module for consistent deployments
- **Flexible Naming**: VMs are automatically named as `{vmNamePrefix}-{index}` (e.g., myVM-1, myVM-2, myVM-3)
- **Network Configuration**: Supports both Dynamic and Static IP allocation
- **Security Options**: Supports TrustedLaunch, disk encryption, and integrity monitoring
- **Comprehensive Outputs**: Returns arrays of VM IDs, names, NIC IDs, and IP addresses

## Parameters

### Key Parameters

| Parameter | Description | Default | Required |
|-----------|-------------|---------|----------|
| `vmNamePrefix` | Base name prefix for VMs | `myVM` | No |
| `vmCount` | Number of VMs to deploy (1-100) | `2` | No |
| `vmSize` | VM size | `Standard_D2s_v3` | No |
| `osType` | OS type (Windows/Linux) | `Linux` | No |
| `adminUsername` | Admin username | `azAdmin` | No |
| `adminPassword` | Admin password | - | Yes |
| `subnetId` | Full resource ID of subnet | - | Yes |

### Network Configuration

- **Dynamic IPs**: Set `privateIPAllocationMethod` to `Dynamic` (default)
- **Static IPs**: Set `privateIPAllocationMethod` to `Static` and provide `privateIPAddresses` array

Example for static IPs:
```bicep
privateIPAllocationMethod: 'Static'
privateIPAddresses: ['10.0.1.10', '10.0.1.11', '10.0.1.12']
```

## Outputs

The deployment provides the following outputs:

- `vmIds`: Array of VM resource IDs
- `vmNames`: Array of VM names
- `nicIds`: Array of NIC resource IDs
- `privateIPAddresses`: Array of private IP addresses

Access outputs after deployment:
```powershell
$deployment = Get-AzResourceGroupDeployment -ResourceGroupName 'myRG' -Name 'deploymentName'
$deployment.Outputs.vmNames.Value
$deployment.Outputs.privateIPAddresses.Value
```

## Notes

- VM names are generated as `{vmNamePrefix}-{index}` where index starts at 1
- Maximum of 100 VMs can be deployed in a single deployment (configurable via @maxValue)
- For Static IP allocation, ensure the `privateIPAddresses` array has enough entries for the `vmCount`
- All VMs are deployed to the same subnet (multi-subnet support can be added by modifying the module)
- Boot diagnostics are enabled by default for all VMs

## Troubleshooting

**Issue**: Deployment fails with "IP address already in use"
- **Solution**: Verify static IP addresses are available in the subnet

**Issue**: Module not found error
- **Solution**: Ensure `modules/vm.bicep` exists relative to `main.bicep`

**Issue**: Parameter validation errors
- **Solution**: Verify all required parameters are provided, especially `adminPassword` and `subnetId`