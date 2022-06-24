param virtualNetworkName01 string
param subnetName string
param networkInterfaceName01 string
param location string

var vnetId = resourceId('Microsoft.Network/virtualNetworks', virtualNetworkName01)
var subnetRef = '${vnetId}/subnets/${subnetName}'

resource networkInterface_01 'Microsoft.Network/networkInterfaces@2020-11-01' = {
  name: networkInterfaceName01
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: subnetRef
          }
          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
    dnsSettings: {
      dnsServers: []
    }
    enableAcceleratedNetworking: false
    enableIPForwarding: false
  }
}
