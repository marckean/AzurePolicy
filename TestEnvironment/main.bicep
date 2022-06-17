targetScope = 'managementGroup'

param RG_name_01 string = 'Company_01'
param RG_name_02 string = 'Company_02'
param location string = 'australiaeast'

var subscriptionID = '7ac51792-8ea1-4ea8-be56-eb515e42aadf'
var tenantID = '8efecb12-cbaa-4612-b850-e6a68c14d336'

//https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/deploy-to-management-group?tabs=azure-cli

// Subscription scope
module RG_01 './resource-group.bicep' = {
  name: 'Company_RG_01'
  scope: subscription(subscriptionID)
  params: {
    location: location
    RG_name: RG_name_01
  }
}

// Subscription scope
module RG_02 './resource-group.bicep' = {
  name: 'Company_RG_02'
  scope: subscription(subscriptionID)
  params: {
    location: location
    RG_name: RG_name_02
  }
}

// Resource Group scope
module StorageAccount_01 './storage-account.bicep' = {
  name: 'Company_StorageAccount_01'
  scope: resourceGroup(subscriptionID, RG_name_01)
  params: {
    location: RG_01.outputs.RGLocation
    globalRedundancy: bool(false)
  }
}

// Resource Group scope
module userAssignedIdentity_01 './userAssignedIdentity.bicep' = {
  name: 'Company_userAssignedIdentity_01'
  scope: resourceGroup(subscriptionID, RG_name_01)
  params: {
    managedIdentityName: 'AzurePolicy_ID'
    location: RG_01.outputs.RGLocation
  }
}

// Resource Group scope
module userAssignedIdentity_02 './userAssignedIdentity.bicep' = {
  name: 'Company_userAssignedIdentity_02'
  scope: resourceGroup(subscriptionID, RG_name_01)
  params: {
    managedIdentityName: 'AzureKeyVault_ID'
    location: RG_01.outputs.RGLocation
  }
}

// Management Group scope
module roleAssignment_01 './roleAssignment.bicep' = {
  name: 'Company_roleAssignment_01'
  scope: managementGroup('Test')
  params: {
    principalId: userAssignedIdentity_01.outputs.principalId
  }
}

// Resource Group scope
module nsg1 './nsg_rules.bicep' = {
  scope: resourceGroup(subscriptionID, RG_name_01)
  name: 'Company_NSG_01'
  params: {
    location: RG_01.outputs.RGLocation
  }
}

// Resource Group scope
module kv1 './KeyVault.bicep' = {
  scope: resourceGroup(subscriptionID, RG_name_01)
  name: 'Company_KeyVault_01'
  params: {
    location: RG_01.outputs.RGLocation
    tenantID: tenantID
    objectID: userAssignedIdentity_02.outputs.principalId
  }
}

// Resource Group scope
module la1 './log-analytics.bicep' = {
  scope: resourceGroup(subscriptionID, RG_name_02)
  name: 'Company_KeyVault_01'
  params: {
    location: RG_02.outputs.RGLocation
  }
}
