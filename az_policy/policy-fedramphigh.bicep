targetScope = 'managementGroup'

param time string = utcNow()
param policyDescription string = 'FedRamp High'
param policyAssignmentName string = 'Fedramp High'
param policyId string = '/providers/Microsoft.Authorization/policySetDefinitions/d5264498-16f4-418a-b659-fa7ef418175f'

var Param = json(loadTextContent('parameters/policy-fedramphigh.json'))

module policyHipaa 'modules/policy-assign.bicep' = {
  name: 'policy-fedramp-${time}'
  params: {
    policyAssignmentEnforcementMode: 'Default'
    policyAssignmentName: policyAssignmentName
    policyDefinitionId: policyId
    policyDescription: policyDescription
    policyParameters: Param //Keeping all defaults
  }
}

