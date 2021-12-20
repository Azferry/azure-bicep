targetScope = 'managementGroup'

param time string = utcNow()
param policyDescription string = 'PCI Policy'
param policyAssignmentName string = 'PCI'
param policyId string = '/providers/Microsoft.Authorization/policySetDefinitions/496eeda9-8f2f-4d5e-8dfd-204f0a92ed41'

// var Param = json(loadTextContent('parameters/policy-pram.json'))

module policyHipaa 'modules/policy-assign.bicep' = {
  name: 'policy-pci-${time}'
  params: {
    policyAssignmentEnforcementMode: 'Default'
    policyAssignmentName: policyAssignmentName
    policyDefinitionId: policyId
    policyDescription: policyDescription
    // policyParameters: Param //Keeping all defaults
  }
}

