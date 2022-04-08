/*

Deployment:
az deployment group create --name ExampleDeployment --resource-group 'rg001' --template-file  'basicdb-main.bicep' --parameters 'basicdb.parameters.json'
*/
param sqlName string
param sqlAdministratorLogin string
param sqlDBTags object = {}

param setAADAdmins bool = false
@description('Principal Type of the sever administrator. Values include Application, Group, User')
param principalType string
param azureADOnlyAuthentication bool = false
param login string
param sid string
param tenantId string

param publicNetworkAccess string = 'Disabled'

@description('SQL Collation')
param sqlCollation string = 'SQL_Latin1_General_CP1_CI_AS'

param sqlDatabases array = []

var location = resourceGroup().location
var sqlPassword = 'P${uniqueString(resourceGroup().id)}-${uniqueString(subscription().id)}x!'

//Set Administrators
var setAdmins = {
  administratorType: 'ActiveDirectory'
  azureADOnlyAuthentication: azureADOnlyAuthentication
  principalType: principalType
  login: login
  sid: sid
  tenantId: tenantId
}

resource sqlServer 'Microsoft.Sql/servers@2021-02-01-preview' = {
  name: sqlName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    administratorLogin: sqlAdministratorLogin
    administratorLoginPassword: sqlPassword
    minimalTlsVersion: '1.2'
    version: '12.0'
    publicNetworkAccess: publicNetworkAccess
    administrators: setAADAdmins ? setAdmins : {}
    restrictOutboundNetworkAccess: 'Disabled'
  }
  tags: sqlDBTags
}

module createSqlmiDBs 'databases/databases.bicep' = {
  name: 'createDBs'
  params: {
    tags: sqlDBTags
    location: location
    sqlManagedInstanceCollation: sqlCollation
    sqlName: sqlServer.name
    sqlDatabases: sqlDatabases
  }
  dependsOn: []
}
