targetScope = 'managementGroup'

param RG_01 string = 'Company_Tier1'
param RG_02 string = 'Company_PaaS'
param RG_03 string = 'Company_IaaS'
param RG_04 string = 'Company_Network'
param RG_05 string = 'Company_Storage'
param location string = 'australiaeast'

var subscriptionID = '7ac51792-8ea1-4ea8-be56-eb515e42aadf'
var tenantID = '8efecb12-cbaa-4612-b850-e6a68c14d336'
var ManagemantGroup = 'Test'

//https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/deploy-to-management-group?tabs=azure-cli

// Subscription scope
module resourceGroup_01 './resource-group.bicep' = {
  name: 'Company_RG_01'
  scope: subscription(subscriptionID)
  params: {
    location: location
    RG_name: RG_01
  }
}

// Subscription scope
module resourceGroup_02 './resource-group.bicep' = {
  name: 'Company_RG_02'
  scope: subscription(subscriptionID)
  params: {
    location: location
    RG_name: RG_02
  }
}

// Resource Group scope
module StorageAccount_01 './storage-account.bicep' = {
  name: 'Company_StorageAccount_01'
  scope: resourceGroup(subscriptionID, RG_05)
  params: {
    location: resourceGroup_01.outputs.RGLocation
    globalRedundancy: bool(false)
  }
}

// Resource Group scope
module userAssignedIdentity_01 './userAssignedIdentity.bicep' = {
  name: 'Company_userAssignedIdentity_01'
  scope: resourceGroup(subscriptionID, RG_01)
  params: {
    managedIdentityName: 'AzurePolicy_ID'
    location: resourceGroup_01.outputs.RGLocation
  }
}

// Resource Group scope
module userAssignedIdentity_02 './userAssignedIdentity.bicep' = {
  name: 'Company_userAssignedIdentity_02'
  scope: resourceGroup(subscriptionID, RG_01)
  params: {
    managedIdentityName: 'AzureKeyVault_ID'
    location: resourceGroup_01.outputs.RGLocation
  }
}

// Management Group scope
module roleAssignment_01 './roleAssignment.bicep' = {
  name: 'Company_roleAssignment_01'
  scope: managementGroup(ManagemantGroup)
  params: {
    principalId: userAssignedIdentity_01.outputs.principalId
  }
}

// Resource Group scope
module nsg1 './nsg_rules.bicep' = {
  scope: resourceGroup(subscriptionID, RG_04)
  name: 'Company_NSG_01'
  params: {
    location: resourceGroup_01.outputs.RGLocation
  }
}

// Resource Group scope
module kv1 './KeyVault.bicep' = {
  scope: resourceGroup(subscriptionID, RG_02)
  name: 'Company_KeyVault_01'
  params: {
    location: resourceGroup_01.outputs.RGLocation
    tenantID: tenantID
    objectID: userAssignedIdentity_02.outputs.principalId
  }
}

// Resource Group scope
module la1 './log-analytics.bicep' = {
  scope: resourceGroup(subscriptionID, RG_02)
  name: 'Company_LogAnalytics_01'
  params: {
    location: resourceGroup_01.outputs.RGLocation
  }
}

// Subscription Group scope
module pa1 './policy_assignments.bicep' = {
  scope: subscription(subscriptionID)
  name: 'Company_PolicyAssignment_01'
  params: {
    location: resourceGroup_01.outputs.RGLocation
  }
}

// Resource Group scope
module virtual_Network_01 './virtual_network.bicep' = {
  scope: resourceGroup(subscriptionID, RG_04)
  name: 'Company_VirtualNetwork_01'
  params: {
    location: resourceGroup_01.outputs.RGLocation
    virtualNetworkName01: 'Company_03-vnet'
    subnetName: 'default'
    subnetAddressPrefix: '10.3.0.0/24'
    bastionSubnetAddressPrefix: '10.3.250.0/26'
    addressSpace_addressPrefixes: ['10.3.0.0/16']
  }
}

// Resource Group scope
module nic_01 './network_interface_card.bicep' = {
  scope: resourceGroup(subscriptionID, RG_04)
  name: 'Company_NIC_01'
  params: {
    location: resourceGroup_01.outputs.RGLocation
    virtualNetworkName01: 'Company_03-vnet'
    subnetName: 'default'
    networkInterfaceName01: 'LA-Test-DCR-01-NIC'
  }
}

// Resource Group scope
module virtual_Machine_01 './virtual_machine.bicep' = {
  scope: resourceGroup(subscriptionID, RG_03)
  name: 'Company_VirtualMachine_01'
  params: {
    location: resourceGroup_01.outputs.RGLocation
    virtualMachineName01: 'LA-Test-DCR-01'
    networkInterfaceName01: 'LA-Test-DCR-01-NIC'
    adminUsername: 'marckean'
    adminPassword: 'Passw0rd2022'
    virtualMachineSize: 'Standard_B2ms'
  }
}

// Resource Group scope
module bastion_01 './bastion.bicep' = {
  scope: resourceGroup(subscriptionID, RG_04)
  name: 'Company_Bastion_01'
  params: {
    location: resourceGroup_01.outputs.RGLocation
    bastionName01: 'Company_03-bastion'
  }
}
