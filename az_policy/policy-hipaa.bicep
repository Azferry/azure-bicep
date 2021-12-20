// targetScope = 'managementGroup' 

targetScope = 'subscription'
param time string = utcNow()
param policyDescription string = 'HIPAA Policy'
param policyAssignmentName string = 'HIPAA'
param policyId string = '/providers/Microsoft.Authorization/policySetDefinitions/a169a624-5599-4385-a696-c8d643089fab'

var hipaaParam = json(loadTextContent('parameters/policy-hipaa.json'))

module policyHipaa 'modules/policy-assign-sub.bicep' = {
  name: 'policy-hipaa-${time}'
  params: {
    policyAssignmentEnforcementMode: 'Default'
    policyAssignmentName: policyAssignmentName
    policyDefinitionId: policyId
    policyDescription: policyDescription
    policyParameters: hipaaParam
  }
}

module assignPolicyRole 'modules/role-assign-sub.bicep' = {
  name: 'roleAssign-${time}'
  params: {
    assignmentName: policyAssignmentName
    principalId: policyHipaa.outputs.policyIdentity
    roleId: 'b24988ac-6180-42a0-ab88-20f7382dd24c'
  }
}
