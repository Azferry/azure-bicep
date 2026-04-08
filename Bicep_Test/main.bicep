targetScope = 'subscription'

param location string
param resourcePrefix string = 'biceptesting'
param tags object = {}


resource rg 'Microsoft.Resources/resourceGroups@2020-06-01' = {
  name: '${resourcePrefix}-rg'
  location: location
  tags: tags
}
