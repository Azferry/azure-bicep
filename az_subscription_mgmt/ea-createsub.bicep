/*
  creates new subscription under an EA agreement

  requirements: Bicep file assumes user has admin rights in EA
  createDate: 2/10/22
  updateDate: 2/17/22
  version: v1
*/

/*
az deployment mg create \
  --name subdeployment \
  --location eastus \
  --management-group-id mg1 \
  --template-file ea-createsub.bicep \
  --parameters subscriptionAliasName='sampleAlias' billingScope='/providers/Microsoft.Billing/BillingAccounts/1234567/enrollmentAccounts/7654321'
*/

targetScope = 'managementGroup'

@description('Provide the alias for the subscription (Display Name of the subscription)')
param subscriptionAliasName string

@description('Provide the full resource ID of billing scope to use for subscription creation.')
param billingScope string

@description('Subscription workload type. Deafult is Production')
param subWorkload string = 'Production'

resource subscriptionAlias 'Microsoft.Subscription/aliases@2020-09-01' = {
  scope: tenant()
  name: subscriptionAliasName
  properties: {
    workload: subWorkload
    displayName: subscriptionAliasName
    billingScope: billingScope
  }
}
