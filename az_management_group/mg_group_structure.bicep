/*
  Creates a management group structure from the enterprise scale landing zones framework

  https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/landing-zone/design-area/resource-org-management-groups
  requirements: Premissions to create a management group 
                az role assignment create --assignee "OBJID" --scope "/" --role "Owner"
  createDate: 3/21/22
  version: v0.1
  example: 
    az deployment mg create --location 'eastus' --template-file 'main.bicep' --management-group-id '<MGGROUPID>'
*/

targetScope = 'managementGroup'

param clientCode string = 'contoso'

resource defaultSub 'Microsoft.Management/managementGroups@2020-05-01' = {
  scope: tenant()
  name: 'default-new-subscription'
  properties: {}
}

resource contosoRoot 'Microsoft.Management/managementGroups@2020-05-01' = {
  scope: tenant()
  name: '${clientCode}-root'
  properties: {}
}

resource landingzones 'Microsoft.Management/managementGroups@2021-04-01' = {
  name: 'landing-zones'
  scope: tenant()
  properties: {
    details: {
      parent: {
        id: contosoRoot.id
      }
    }
  }
}

resource landingzonesNPD 'Microsoft.Management/managementGroups@2021-04-01' = {
  name: 'npd'
  scope: tenant()
  properties: {
    details: {
      parent: {
        id: landingzones.id
      }
    }
  }
}

resource landingzonesPRD 'Microsoft.Management/managementGroups@2021-04-01' = {
  name: 'prd'
  scope: tenant()
  properties: {
    details: {
      parent: {
        id: landingzones.id
      }
    }
  }
}

resource core 'Microsoft.Management/managementGroups@2021-04-01' = {
  name: 'platform'
  scope: tenant()
  properties: {
    details: {
      parent: {
        id: contosoRoot.id
      }
    }
  }
}

resource coreNetwork 'Microsoft.Management/managementGroups@2021-04-01' = {
  name: 'networking'
  scope: tenant()
  properties: {
    details: {
      parent: {
        id: core.id
      }
    }
  }
}

resource coreMgmt 'Microsoft.Management/managementGroups@2021-04-01' = {
  name: 'management'
  scope: tenant()
  properties: {
    details: {
      parent: {
        id: core.id
      }
    }
  }
}

resource coreID 'Microsoft.Management/managementGroups@2021-04-01' = {
  name: 'identity'
  scope: tenant()
  properties: {
    details: {
      parent: {
        id: core.id
      }
    }
  }
}

resource sandbox 'Microsoft.Management/managementGroups@2021-04-01' = {
  name: 'sandbox'
  scope: tenant()
  properties: {
    details: {
      parent: {
        id: contosoRoot.id
      }
    }
  }
}

resource decom 'Microsoft.Management/managementGroups@2021-04-01' = {
  name: 'decommissioned'
  scope: tenant()
  properties: {
    details: {
      parent: {
        id: contosoRoot.id
      }
    }
  }
}


output newManagementGroup string = clientCode
