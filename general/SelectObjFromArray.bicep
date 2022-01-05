param location string = resourceGroup().location
param locationCode object = {
  eastus: 'eus'
  eastus2: 'eus2'
} 

param companycode string = 'msft-'

output substringOutput string = '${companycode}${locationCode[location]}'
// output substringOutput string = '${companycode}${locationCode['eastus']}'
