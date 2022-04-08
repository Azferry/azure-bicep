param sqlDatabases array = []
param sqlName string = ''
param location string = ''
param tags object = {}
param sqlManagedInstanceCollation string = ''

resource sqlDBs 'Microsoft.Sql/servers/databases@2020-11-01-preview' = [for dbName in sqlDatabases: {
  name: '${sqlName}/${dbName.name}'
  location: location
  tags: tags
  dependsOn: []
  sku: {
    name: dbName.skuName
    tier: dbName.skuTier
    family: dbName.skuFamily
    capacity: dbName.skuCapacity
  }
  properties: {
    collation: sqlManagedInstanceCollation
    licenseType: dbName.licenseType
    sampleName: dbName.sampleName
  }
}]

resource sqlDBsShortTermRetention 'Microsoft.Sql/servers/databases/backupShortTermRetentionPolicies@2021-02-01-preview' = [for dbName in sqlDatabases: {
  name: '${sqlName}/${dbName.name}/default'
  properties: {
    retentionDays: dbName.dbShortTermRetentionDays
    diffBackupIntervalInHours: dbName.dbDiffBackupIntervalInHours
  }
  dependsOn: [
    sqlDBs
  ]
}]

resource sqlDBsLongTermRetention 'Microsoft.Sql/servers/databases/backupLongTermRetentionPolicies@2021-05-01-preview' = [for dbName in sqlDatabases: {
  name: '${sqlName}/${dbName.name}/default'
  properties: {
    monthlyRetention: dbName.monthlyRetention
    weeklyRetention: dbName.weeklyRetention
    weekOfYear: dbName.weekOfYear
    yearlyRetention: dbName.yearlyRetention
  }
  dependsOn: [
    sqlDBs
  ]
}]
