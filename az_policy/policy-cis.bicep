targetScope = 'managementGroup'

param time string = utcNow()
param policyDescription string = 'CIS'
param policyAssignmentName string = 'CIS'
param policyId string = '/providers/Microsoft.Authorization/policySetDefinitions/612b5213-9160-4969-8578-1518bd2a000c'

// var Param = json(loadTextContent('parameters/policy-fedramphigh.json'))

module policyHipaa 'modules/policy-assign.bicep' = {
  name: 'policy-cis-${time}'
  params: {
    policyAssignmentEnforcementMode: 'Default'
    policyAssignmentName: policyAssignmentName
    policyDefinitionId: policyId
    policyDescription: policyDescription
    // policyParameters: Param //Keeping all defaults
  }
}

