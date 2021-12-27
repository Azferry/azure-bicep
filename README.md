# Azure Bicep
Getting started with Azure Bicep

# Run Bicep using AZ CLI

## Resource Group
``` 
az deployment group create \
  --name RgDeployment \
  --location "centralus" \
  --resource-group "RGNAME" \
  --template-file .\main.bicep 
```
## Subscription
```
az deployment sub create \
  --name SubDeployment \
  --location "centralus" \
  --template-file .\main.bicep
```
## Management Group
```
az deployment mg create \
  --name PolicyDeployment \
  --location "centralus" \
  --management-group-id "managementGroup" \
  --template-file .\main.bicep
```
# Run Bicep with Powershell

## Resource Group
``` 
New-AzResourceGroupDeployment `
  -Name myStorageDeployment1 `
  -ResourceGroupName rg-bicep `
  -TemplateFile main.bicep `
  -TemplateParameterFile main.parameters.json `
  -location centralus
```
## Subscription
```
New-AzSubscriptionDeployment `
  -Name SubDeployment `
  -Location centralus `
  -TemplateFile main.bicep `
  -TemplateParameterFile main.parameters.json `
  -rgName demoResourceGroup `
  -rgLocation centralus
```
## Management Group
```
New-AzManagementGroupDeployment `
  -Name demoMGDeployment `
  -Location "West US" `
  -ManagementGroupId "myMG" `
  -TemplateParameterFile main.parameters.json `
  -TemplateFile main.bicep 
```

# Convert Bicep
## Convert Bicep to ARM 
This will output a ARM Template JSON File from an bicep file. 
```
az bicep build --file main.bicep
```

## Convert ARM to Bicep 
This will take an existing ARM Template and convert it to Bicep. This will attempt to convert but does not guaranteed mapping from ARM template json to bicep. 
[MSFT Documentation](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/decompile?tabs=azure-cli)
```
az bicep decompile --file main.json
```
