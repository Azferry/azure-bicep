targetScope = 'managementGroup'

var policyName = 'audit-resource-tag'
var policyDisplayName = 'Audit a tag format on resources'
var policyDescription = 'Audits existence of a tag format. Does not apply to resource groups.'
param time string = utcNow()

var tagParam = json(loadTextContent('parameters/append_tag_parameters.json'))
var tagRule = json(loadTextContent('policy/append_rg_tag.json'))



resource policy 'Microsoft.Authorization/policyDefinitions@2020-09-01' = {
  name: policyName
  properties: {
    displayName: policyDisplayName
    description: policyDescription
    policyType: 'Custom'
    mode: 'Indexed'
    metadata: {
      category: 'Tags'
    }
    parameters: tagParam
    policyRule: tagRule
  }
}

