targetScope = 'subscription'

@description('Location for the resourceGroup')
@allowed([
  'eastus'
  'eastus2'
  'westus'
])
param resourceGroupLocation string

@description('What is the charge back code?')
param chargecode string

@description('Name of resoruce group')
param resourceGroupName string


resource ResourceGroup 'Microsoft.Resources/resourceGroups@2019-10-01' = {
  name: resourceGroupName
  location: resourceGroupLocation
  tags: {
    chargecode: chargecode
  }
  properties: {}
}
