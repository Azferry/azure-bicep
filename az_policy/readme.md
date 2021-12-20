# Deploy Azure Policy with Bicep

## How to Deploy?

### Resource Group

```powershell
az deployment group create --name ExampleDeployment --location "centralus"   --resource-group "RGNAME" --template-file .\policy-hipaa.bicep
```

### Subscription

```powershell
az deployment sub create --name ExampleDeployment --location "centralus"  --template-file .\policy-hipaa.bicep 
```

### Management Group

```powershell
az deployment mg create --name PolicyDeployment --location "centralus" --management-group-id "mg-platform"   --template-file .\policy-rg-tagging.bicep
```

## How to get parameters for a policy

```powershell
(Get-AzPolicySetDefinition -id '/providers/Microsoft.Authorization/policySetDefinitions/d5264498-16f4-418a-b659-fa7ef418175f' ).Properties.Parameters
```
