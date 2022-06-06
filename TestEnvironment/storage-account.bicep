param location string = resourceGroup().location
param globalRedundancy bool = false

var WrongStorageAccountName = '${'wrong'}${uniqueString(resourceGroup().id)}' // generates unique name based on resource group ID
var RightStorageAccountName = '${'right'}${uniqueString(resourceGroup().id)}' // generates unique name based on resource group ID
var storageSku = globalRedundancy ? 'Standard_GRS' : 'Standard_LRS' // if true --> GRS, else --> LRS
 
resource stg1 'Microsoft.Storage/storageAccounts@2019-06-01' = {
    name: WrongStorageAccountName
    location: location
    kind: 'Storage'
    sku: {
        name: storageSku
    }
    properties:{
        minimumTlsVersion: 'TLS1_0'
        supportsHttpsTrafficOnly: false
        allowBlobPublicAccess: true
    }
}

resource stg2 'Microsoft.Storage/storageAccounts@2019-06-01' = {
    name: RightStorageAccountName
    location: location
    kind: 'Storage'
    sku: {
        name: storageSku
    }
    properties:{
        minimumTlsVersion: 'TLS1_2'
        supportsHttpsTrafficOnly: true
        allowBlobPublicAccess: false
    }
}
 
output storageId string = stg1.id
