targetScope = 'managementGroup'

param RG_name string = 'HomeAffairs_01'
param location string = 'australiaeast'

var subscriptionID = '7ac51792-8ea1-4ea8-be56-eb515e42aadf'
var tenantID = '8efecb12-cbaa-4612-b850-e6a68c14d336'

//https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/deploy-to-management-group?tabs=azure-cli
module RG_01 './resource-group.bicep' = {
  name: 'HomeAffairs_RG_01'
  scope: subscription(subscriptionID)
  params: {
    location: location
    RG_name: RG_name
  }
}

module StorageAccount_01 './storage-account.bicep' = {
  name: 'HomeAffairs_StorageAccount_01'
  scope: resourceGroup(subscriptionID, RG_name)
  params: {
    location: RG_01.outputs.RGLocation
    globalRedundancy: bool(false)
  }
}

module userAssignedIdentity_01 './userAssignedIdentity.bicep' = {
  name: 'HomeAffairs_userAssignedIdentity_01'
  scope: resourceGroup(subscriptionID, RG_name)
  params: {
    managedIdentityName: 'AzurePolicy_ID'
    location: RG_01.outputs.RGLocation
  }
}

module userAssignedIdentity_02 './userAssignedIdentity.bicep' = {
  name: 'HomeAffairs_userAssignedIdentity_02'
  scope: resourceGroup(subscriptionID, RG_name)
  params: {
    managedIdentityName: 'AzureKeyVault_ID'
    location: RG_01.outputs.RGLocation
  }
}

module roleAssignment_01 './roleAssignment.bicep' = {
  name: 'HomeAffairs_roleAssignment_01'
  scope: managementGroup('Test')
  params: {
    principalId: userAssignedIdentity_01.outputs.principalId
  }
}

module nsg1 './nsg.bicep' = {
  scope: resourceGroup(subscriptionID, RG_name)
  name: 'HomeAffairs_NSG_01'
  params: {
    location: RG_01.outputs.RGLocation
  }
}

module kv1 './KeyVault.bicep' = {
  scope: resourceGroup(subscriptionID, RG_name)
  name: 'HomeAffairs_KeyVault_01'
  params: {
    location: RG_01.outputs.RGLocation
    tenantID: tenantID
    objectID: userAssignedIdentity_02.outputs.principalId
  }
}
