param virtualNetworkName01 string
param location string
param subnetName string
param subnetAddressPrefix string
param bastionSubnetAddressPrefix string
param addressSpace_addressPrefixes array

resource virtualNetwork01 'Microsoft.Network/virtualNetworks@2020-11-01' = {
  name: virtualNetworkName01
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: addressSpace_addressPrefixes
    }
    virtualNetworkPeerings: []
    enableDdosProtection: false
  }
}

resource virtualNetworkSubnets01 'Microsoft.Network/virtualNetworks/subnets@2020-11-01' = {
  parent: virtualNetwork01
  name: subnetName
  properties: {
    addressPrefix: subnetAddressPrefix
    delegations: []
    privateEndpointNetworkPolicies: 'Enabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
}

resource virtualNetworkSubnets02 'Microsoft.Network/virtualNetworks/subnets@2020-11-01' = {
  parent: virtualNetwork01
  name: 'AzureBastionSubnet'
  properties: {
    addressPrefix: bastionSubnetAddressPrefix
    delegations: []
    privateEndpointNetworkPolicies: 'Enabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
}
