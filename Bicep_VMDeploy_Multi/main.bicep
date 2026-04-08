targetScope = 'resourceGroup'

// ──────────────────────────────────────────────
// Parameters
// ──────────────────────────────────────────────

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Base name prefix for the virtual machines. VMs will be named as {vmNamePrefix}-{index}')
param vmNamePrefix string = 'myVM'

@description('Number of virtual machines to deploy.')
@minValue(1)
@maxValue(100)
param vmCount int = 2

@description('The size of the virtual machine (e.g. Standard_D2s_v3).')
param vmSize string = 'Standard_D2s_v3'

@description('OS Type - Windows or Linux')
@allowed(['Windows', 'Linux'])
param osType string = 'Linux'

@description('The admin username for the virtual machine.')
param adminUsername string = 'azAdmin'

@secure()
@description('The admin password for the virtual machine.')
param adminPassword string

// ── Image Reference ──

@description('Image Reference Publisher (e.g. MicrosoftWindowsServer, Canonical)')
param imageReferencePublisher string = 'RedHat'

@description('Image Reference Offer (e.g. WindowsServer, 0001-com-ubuntu-server-jammy)')
param imageReferenceOffer string = 'RHEL'

@description('Image Reference SKU (e.g. 2022-datacenter-g2, 22_04-lts-gen2)')
param imageReferenceSku string = '8-lvm-gen2'

@description('Image Reference Version. Default: latest')
param imageReferenceVersion string = 'latest'

// ── Disk Encryption Set ──

@description('The resource ID of the Disk Encryption Set (DES) used to encrypt OS and data disks. Leave empty to use platform-managed keys.')
param diskEncryptionSetId string = ''

// ── Network / Subnet ──

@description('The full resource ID of the subnet the VM NIC will be attached to. Example: /subscriptions/{sub}/resourceGroups/{rg}/providers/Microsoft.Network/virtualNetworks/{vnet}/subnets/{subnet}')
param subnetId string = ''

@description('Private IP address allocation method.')
@allowed(['Dynamic', 'Static'])
param privateIPAllocationMethod string = 'Dynamic'

@description('Static private IP addresses for each VM. Only used when privateIPAllocationMethod is Static. Array length should match vmCount.')
param privateIPAddresses array = []

@description('Enable accelerated networking on the NIC.')
param enableAcceleratedNetworking bool = false

@description('Deploy Network Security Group')
param deployNSG bool = false

@description('Network Security Group attached at Nic level.')
param nsgId string = ''

// ── OS Disk ──

@description('OS disk size in GB.')
param osDiskSizeGB int = 127

@description('OS disk storage account type.')
@allowed(['Premium_LRS', 'Premium_ZRS', 'StandardSSD_LRS', 'StandardSSD_ZRS', 'Standard_LRS'])
param osDiskType string = 'Premium_LRS'

// ── Data Disk (optional) ──

@description('Data disk size in GB. Set to 0 to skip data disk creation.')
param dataDiskSizeGB int = 100

@description('Data disk storage account type.')
@allowed(['Premium_LRS', 'Premium_ZRS', 'StandardSSD_LRS', 'StandardSSD_ZRS', 'Standard_LRS'])
param dataDiskType string = 'Premium_LRS'

// ── Security ──

@description('Specifies the SecurityType of the virtual machine. It is set as TrustedLaunch to enable UefiSettings. Default: UefiSettings will not be enabled unless this property is set as TrustedLaunch.')
@allowed([
  'Standard'
  'TrustedLaunch'
  'ConfidentialVM'
])
param securityType string = 'Standard'

@description('Enable Secure Boot (only applies when securityType is TrustedLaunch).')
param secureBoot bool = true

@description('Enable vTPM (only applies when securityType is TrustedLaunch).')
param vTPM bool = true

@description('Enable encryption at host for the virtual machine.')
param encryptionAtHost bool = false

@description('The resource ID of the availability set for the virtual machine. Leave empty to not use an availability set.')
param avsetId string = ''

@description('Specifies whether integrity monitoring will be added to the virtual machine.')
param integrityMonitoring bool = false

// ── Licensing ──

@description('License type. Use Windows_Server for Azure Hybrid Benefit.')
@allowed(['Windows_Server', 'None'])
param licenseType string = 'None'

// ── Tags ──

@description('Tags to apply to all resources.')
param tags object = {}

// ──────────────────────────────────────────────
// Module Deployments - Loop through N VMs
// ──────────────────────────────────────────────

module virtualMachines 'modules/vm.bicep' = [for i in range(0, vmCount): {
  name: 'vm-deployment-${i}'
  params: {
    location: location
    vmName: '${vmNamePrefix}${i + 1}'
    vmSize: vmSize
    osType: osType
    adminUsername: adminUsername
    adminPassword: adminPassword
    imageReferencePublisher: imageReferencePublisher
    imageReferenceOffer: imageReferenceOffer
    imageReferenceSku: imageReferenceSku
    imageReferenceVersion: imageReferenceVersion
    diskEncryptionSetId: diskEncryptionSetId
    subnetId: subnetId
    privateIPAllocationMethod: privateIPAllocationMethod
    privateIPAddress: privateIPAllocationMethod == 'Static' && length(privateIPAddresses) > i ? privateIPAddresses[i] : ''
    enableAcceleratedNetworking: enableAcceleratedNetworking
    deployNSG: deployNSG
    nsgId: nsgId
    osDiskSizeGB: osDiskSizeGB
    osDiskType: osDiskType
    dataDiskSizeGB: dataDiskSizeGB
    dataDiskType: dataDiskType
    securityType: securityType
    secureBoot: secureBoot
    vTPM: vTPM
    encryptionAtHost: encryptionAtHost
    avsetId: avsetId
    integrityMonitoring: integrityMonitoring
    licenseType: licenseType
    tags: tags
  }
}]

// ──────────────────────────────────────────────
// Outputs
// ──────────────────────────────────────────────

@description('Array of deployed VM resource IDs.')
output vmIds array = [for i in range(0, vmCount): virtualMachines[i].outputs.vmId]

@description('Array of deployed VM names.')
output vmNames array = [for i in range(0, vmCount): virtualMachines[i].outputs.vmName]

@description('Array of deployed VM NIC resource IDs.')
output nicIds array = [for i in range(0, vmCount): virtualMachines[i].outputs.nicId]

@description('Array of private IP addresses assigned to VMs.')
output privateIPAddresses array = [for i in range(0, vmCount): virtualMachines[i].outputs.privateIPAddress]
