param bastionName01 string
param location string


resource bastion01 'Microsoft.Network/bastionHosts@2021-08-01' = {
  name: bastionName01
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    enableFileCopy: true
    disableCopyPaste: false
  }
}
