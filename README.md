# azure_bicep
Example Bicep templates to get started.

# How to Run Bicep 


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
