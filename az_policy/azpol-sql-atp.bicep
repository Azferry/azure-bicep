targetScope = 'managementGroup'

var policyName = 'SQL ATP Enable - Server Level'
var policyDisplayName = 'SQL ATP Server Level - Enable'
var policyDescription = 'Audits existence of a tag format. Does not apply to resource groups.'
param time string = utcNow()

// var tagParam = json(loadTextContent('parameters/pram-sql-atp.json'))
var tagRule = json(loadTextContent('policy/sql-atp.json'))

resource policy 'Microsoft.Authorization/policyDefinitions@2020-09-01' = {
  name: policyName
  properties: {
    displayName: policyDisplayName
    description: policyDescription
    policyType: 'Custom'
    mode: 'Indexed'
    metadata: {
      category: 'Security'
    }
    parameters: {} //tagParam
    policyRule: tagRule
  }
}
