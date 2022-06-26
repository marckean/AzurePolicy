param subnetName string
param subnetAddressPrefix string
param virtualNetworkName string

resource vnet 'Microsoft.Network/virtualNetworks@2021-05-01' existing = {
  name: virtualNetworkName
}

//var vnetID = resourceId('Microsoft.Network/virtualNetworks', virtualNetworkName)

resource virtualNetworkSubnet 'Microsoft.Network/virtualNetworks/subnets@2021-08-01' = {
  parent: vnet
  name: subnetName
  properties: {
    addressPrefix: subnetAddressPrefix
    delegations: []
    privateEndpointNetworkPolicies: 'Enabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
}
