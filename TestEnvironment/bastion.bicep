param bastionName string
param location string

resource bastion01 'Microsoft.Network/bastionHosts@2021-08-01' = {
  name: bastionName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    enableFileCopy: true
    disableCopyPaste: false
  }
}
