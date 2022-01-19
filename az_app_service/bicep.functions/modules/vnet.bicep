
resource virtualNetwork 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: 'vnet-dev-eus2-001'
  location: resourceGroup().location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'snet-functionapp'
        properties: {
          addressPrefix: '10.0.0.0/28'
          delegations: [
            {
              properties: {
                serviceName: 'Microsoft.Web/serverFarms'
              }
              name: 'Microsoft.Web/serverFarms'
            }
          ]
          serviceEndpoints: [
            {
              service: 'microsoft.storage'
              
            }
          ]
        }
        
      }
      {
        name: 'snet-main'
        properties: {
          addressPrefix: '10.0.1.0/24'
        }
      }
    ]
  }
}


output vnetResourceId string = virtualNetwork.id
// output vnetSubnetId string = virtualNetwork.properties.subnets
