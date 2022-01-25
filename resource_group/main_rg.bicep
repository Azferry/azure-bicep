targetScope = 'subscription'

/*
  This Bicep file deployes a resource group with the required tags.

  This Bicep file assumes az cli is set to the right account. 
    Check current account - az account show
    List accouts options - az account list -o table
    Set account - az account set --subscription <name of subscription>

  Deploy Bicep AZ CLI
    az deployment sub create --location eastus --template-file ./main_rg.bicep

  Change Log
  V0.1 Initial Release - 1/19/22
*/

@description('What is the Environment Type?')
@allowed([
  'dev'
  'tst'
  'prd'
])
param targetEnv string

@description('What is the App Name or Code?')
param appName string

@description('What is the Division or BU?')
param division string

@description('Who is the Resource Group Owner?')
param owner string

@description('What is the charge back code?')
param chargecode string

@description('Location for the resourceGroup')
@allowed([
  'eastus'
  'eastus2'
  'westus'
])
param resourceGroupLocation string

@description('principalId of the user or group that will access to the resourceGroup')
param principalId string = '< Principle ID of Group or User>'

@description('roleDefinition to apply to the resourceGroup - default is contributor')
param roleDefinitionId string = '< Role Definition ID >'

var roleID = '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/${roleDefinitionId}'
var resourceGroupName = '${toLower(appName)}-${toLower(targetEnv)}-rg'
var storageAccountName = '${toLower(appName)}${toLower(targetEnv)}sa01'
var nsgName = '${toLower(appName)}${toLower(targetEnv)}nsg01'
var roleAssignmentName  = guid(principalId, roleDefinitionId, appName)

resource ResourceGroup 'Microsoft.Resources/resourceGroups@2019-10-01' = {
  name: resourceGroupName
  location: resourceGroupLocation
  tags: {
    division: division
    environment: targetEnv
    chargecode: chargecode
    appname: appName
    owner: owner
  }
  properties: {}
}

module applyLock 'lock.bicep' = {
  name: 'applyLock'
  scope: ResourceGroup
}

module assignRole 'role.bicep' = {
  name: 'assignRBACRole'
  scope: ResourceGroup
  params: {
    principalId: principalId
    roleNameGuid: roleAssignmentName
    roleDefinitionId: roleID
  }
}

module defaultResources 'defaultRgResources.bicep' = {
  name: 'deployDefaultResources'
  scope: ResourceGroup
  params: {
    saName: storageAccountName
    nsgName: nsgName
  }
}
