targetScope = 'managementGroup'

param time string = utcNow()
param policyDescription string = 'IRS'
param policyAssignmentName string = 'IRS'
param policyId string = '/providers/Microsoft.Authorization/policySetDefinitions/105e0327-6175-4eb2-9af4-1fba43bdb39d'

var Param = json(loadTextContent('parameters/policy-irs.json'))

module policyHipaa 'modules/policy-assign.bicep' = {
  name: 'policy-irs-${time}'
  params: {
    policyAssignmentEnforcementMode: 'Default'
    policyAssignmentName: policyAssignmentName
    policyDefinitionId: policyId
    policyDescription: policyDescription
    policyParameters: Param //Keeping all defaults
  }
}

