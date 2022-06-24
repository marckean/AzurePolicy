param virtualMachines_LA_Test_DCR_01_name string = 'LA-Test-DCR-01'
param virtualNetworkName01 string = 'Company_03-vnet'
param networkInterfaces_la_test_dcr_01273_name string = 'la-test-dcr-01273'
param location string = resourceGroup().location

resource virtualNetwork01 'Microsoft.Network/virtualNetworks@2020-11-01' = {
  name: virtualNetworkName01
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.3.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'default'
        properties: {
          addressPrefix: '10.3.0.0/24'
          delegations: []
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
    ]
    virtualNetworkPeerings: []
    enableDdosProtection: false
  }
}

resource virtualNetworkSubnets01 'Microsoft.Network/virtualNetworks/subnets@2020-11-01' = {
  parent: virtualNetwork01
  name: 'default'
  properties: {
    addressPrefix: '10.3.0.0/24'
    delegations: []
    privateEndpointNetworkPolicies: 'Enabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
}
