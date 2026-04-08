targetScope = 'resourceGroup'

// ──────────────────────────────────────────────
// Parameters
// ──────────────────────────────────────────────

@description('Location for all resources.')
param location string = resourceGroup().location

@description('The name of the virtual machine.')
param vmName string

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
param subnetId string

@description('Private IP address allocation method.')
@allowed(['Dynamic', 'Static'])
param privateIPAllocationMethod string = 'Dynamic'

@description('Static private IP address. Only used when privateIPAllocationMethod is Static.')
param privateIPAddress string = ''

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
// Variables
// ──────────────────────────────────────────────

var nicName = '${vmName}-nic'
var osDiskName = '${vmName}-osdisk'

var useDes = !empty(diskEncryptionSetId)

var osDiskManagedDisk = useDes
  ? {
      storageAccountType: osDiskType
      diskEncryptionSet: {
        id: diskEncryptionSetId
      }
    }
  : {
      storageAccountType: osDiskType
    }

var dataDiskManagedDisk = useDes
  ? {
      storageAccountType: dataDiskType
      diskEncryptionSet: {
        id: diskEncryptionSetId
      }
    }
  : {
      storageAccountType: dataDiskType
    }

var securityProfile = securityType == 'TrustedLaunch'
  ? {
      uefiSettings: ((securityType == 'TrustedLaunch') || (securityType == 'ConfidentialVM')) ? {
        secureBootEnabled: secureBoot
        vTpmEnabled: vTPM
      } : null
      securityType: ((securityType == 'TrustedLaunch') || (securityType == 'ConfidentialVM')) ? securityType : null
      encryptionAtHost: encryptionAtHost ? encryptionAtHost : null
    }
  : null
  

// ──────────────────────────────────────────────
// Resources
// ──────────────────────────────────────────────
// Network Security Group
resource res_nsg 'Microsoft.Network/networkSecurityGroups@2022-09-01' = if (empty(nsgId) && deployNSG) {
  name: '${vmName}-nsg'
  tags: tags
  location: location
}

// Network Interface
resource nic 'Microsoft.Network/networkInterfaces@2023-09-01' = {
  name: nicName
  location: location
  tags: tags
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig'
        properties: {
          privateIPAllocationMethod: privateIPAllocationMethod
          privateIPAddress: privateIPAllocationMethod == 'Static' ? privateIPAddress : null
          subnet: {
            id: subnetId
          }
          primary: true
          privateIPAddressVersion: 'IPv4'
        }
      }
    ]
    enableAcceleratedNetworking: enableAcceleratedNetworking
    networkSecurityGroup: deployNSG ? (empty(nsgId)
      ? {
          id: res_nsg.id
        }
      : {
          id: nsgId
        }) : null
  }
}

// Virtual Machine
resource vm 'Microsoft.Compute/virtualMachines@2024-07-01' = {
  name: vmName
  location: location
  tags: tags
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: imageReferencePublisher
        offer: imageReferenceOffer
        sku: imageReferenceSku
        version: imageReferenceVersion
      }
      osDisk: {
        name: osDiskName
        osType: osType
        diskSizeGB: osDiskSizeGB
        createOption: 'FromImage'
        deleteOption: 'Delete'
        managedDisk: osDiskManagedDisk
      }
      dataDisks: dataDiskSizeGB > 0
        ? [
            {
              name: '${vmName}-datadisk-0'
              diskSizeGB: dataDiskSizeGB
              lun: 0
              createOption: 'Empty'
              deleteOption: 'Delete'
              managedDisk: dataDiskManagedDisk
            }
          ]
        : []
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
          properties: {
            deleteOption: 'Delete'
          }
        }
      ]
    }
    securityProfile: securityProfile
    licenseType: licenseType
    availabilitySet: !empty(avsetId)
      ? {
          id: avsetId
        }
      : null
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
}

resource GuestAttestation 'Microsoft.Compute/virtualMachines/extensions@2018-10-01' = if (integrityMonitoring) {
  name: 'GuestAttestation'
  parent: vm
  location: location
  properties: {
    publisher: 'Microsoft.Azure.Security.WindowsAttestation'
    type: 'GuestAttestation'
    typeHandlerVersion: '1.0'
    autoUpgradeMinorVersion: true
    settings: {
      AttestationConfig: {
        MaaSettings: {
          maaEndpoint: ''
          maaTenantName: 'GuestAttestation'
        }
        AscSettings: {
          ascReportingEndpoint: ''
          ascReportingFrequency: ''
        }
        useCustomToken: 'false'
        disableAlerts: 'false'
      }
    }
  }
}

// ──────────────────────────────────────────────
// Outputs
// ──────────────────────────────────────────────

@description('The resource ID of the virtual machine.')
output vmId string = vm.id

@description('The name of the virtual machine.')
output vmName string = vm.name

@description('The resource ID of the network interface.')
output nicId string = nic.id

@description('The private IP address of the virtual machine.')
output privateIPAddress string = nic.properties.ipConfigurations[0].properties.privateIPAddress
