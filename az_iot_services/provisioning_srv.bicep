


resource iotDPS 'Microsoft.Devices/provisioningServices@2021-10-15' = {
  name: 'iot-dps-d-02'
  location: 'eastus'

  sku: {
    capacity: 1
    name: 'S1'
  }
  properties: {
    allocationPolicy: 'Hashed'
    authorizationPolicies: [
      {
        keyName: 'saskey01'
        rights: 'EnrollmentWrite'
      }
      {
        keyName: 'saskey02'
        rights: 'EnrollmentWrite'
      }
    ]
    enableDataResidency: false
  }
}
