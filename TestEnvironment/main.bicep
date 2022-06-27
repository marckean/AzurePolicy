targetScope = 'managementGroup'

// Resource Groups
var resourceGroups_var = [
  {
    name: 'Company_RG_01'
    location: 'australiaeast'
    resourceGroupName: 'Company_Tier1'
  }
  {
    name: 'Company_RG_02'
    location: 'australiaeast'
    resourceGroupName: 'Company_PaaS'
  }
  {
    name: 'Company_RG_03'
    location: 'australiaeast'
    resourceGroupName: 'Company_IaaS'
  }
  {
    name: 'Company_RG_04'
    location: 'australiaeast'
    resourceGroupName: 'Company_Network'
  }
  {
    name: 'Company_RG_05'
    location: 'australiaeast'
    resourceGroupName: 'Company_Storage'
  }
]

// Virtual Networks
var virtualNetworks_var = [
  {
    name: 'Company_VirtualNetwork_01'
    virtualNetworkName: 'Company_vNet_01'  
    addressSpace_addressPrefixes: [
      '10.3.0.0/16'
    ]
  }
]

// Subnets
var subnets_var = [
  {
    name: 'Company_Subnet_01'
    subnetName: 'First'
    virtualNetworkName: virtualNetworks_var[0].virtualNetworkName
    privateEndpointNetworkPolicies: 'Enabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
    addressPrefix: '10.3.0.0/24'
  }
  {
    name: 'Company_Subnet_02'
    subnetName: 'AzureBastionSubnet'
    virtualNetworkName: virtualNetworks_var[0].virtualNetworkName
    privateEndpointNetworkPolicies: 'Enabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
    addressPrefix: '10.3.250.0/26' 
  }
]

// Tenant
var subscriptionID = '7ac51792-8ea1-4ea8-be56-eb515e42aadf'
var tenantID = '8efecb12-cbaa-4612-b850-e6a68c14d336'
var ManagemantGroup = 'Test'

//Storage
var globalRedundancy = false
var storageSku = globalRedundancy ? 'Standard_GRS' : 'Standard_LRS' // if true --> GRS, else --> LRS
var storageAccounts = [
  {
    name: 'Company_StorageAccount_wrong'
    storageAccountNamePrefex: 'wrong'
    minimumTlsVersion: 'TLS1_0'
    supportsHttpsTrafficOnly: false
    allowBlobPublicAccess: true
  }
  {
    name: 'Company_StorageAccount_right'
    storageAccountNamePrefex: 'right'
    minimumTlsVersion: 'TLS1_2'
    supportsHttpsTrafficOnly: true
    allowBlobPublicAccess: false
  }
]

//https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/deploy-to-management-group?tabs=azure-cli

// Subscription scope
module resourceGroupModule './resource-group.bicep' = [for RG in resourceGroups_var: {
  name: RG.name
  scope: subscription(subscriptionID)
  params: {
    location: RG.location
    RG_name: RG.resourceGroupName
  }
}]

// Subscription scope


// Resource Group scope
module storageAcct './storage-account.bicep' = [for storageAccount in storageAccounts: {
  name: storageAccount.name
  scope: resourceGroup(subscriptionID, resourceGroups_var[4].resourceGroupName)
  params: {
    location: resourceGroupModule[0].outputs.RGLocation
    storageAccountNamePrefex: storageAccount.storageAccountNamePrefex
    minimumTlsVersion: storageAccount.minimumTlsVersion
    supportsHttpsTrafficOnly: storageAccount.supportsHttpsTrafficOnly
    allowBlobPublicAccess: storageAccount.allowBlobPublicAccess
    storageSku: storageSku
    
  }
}]

// Resource Group scope
module userAssignedIdentity_01 './userAssignedIdentity.bicep' = {
  name: 'Company_userAssignedIdentity_01'
  scope: resourceGroup(subscriptionID, resourceGroups_var[0].resourceGroupName)
  params: {
    managedIdentityName: 'AzurePolicy_ID'
    location: resourceGroupModule[0].outputs.RGLocation
  }
}

// Resource Group scope
module userAssignedIdentity_02 './userAssignedIdentity.bicep' = {
  name: 'Company_userAssignedIdentity_02'
  scope: resourceGroup(subscriptionID, resourceGroups_var[0].resourceGroupName)
  params: {
    managedIdentityName: 'AzureKeyVault_ID'
    location: resourceGroupModule[0].outputs.RGLocation
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
  scope: resourceGroup(subscriptionID, resourceGroups_var[3].resourceGroupName)
  name: 'Company_NSG_01'
  params: {
    location: resourceGroupModule[0].outputs.RGLocation
  }
}

// Resource Group scope
module kv1 './KeyVault.bicep' = {
  scope: resourceGroup(subscriptionID, resourceGroups_var[1].resourceGroupName)
  name: 'Company_KeyVault_01'
  params: {
    location: resourceGroupModule[0].outputs.RGLocation
    tenantID: tenantID
    objectID: userAssignedIdentity_02.outputs.principalId
  }
}

// Resource Group scope
module la1 './log-analytics.bicep' = {
  scope: resourceGroup(subscriptionID, resourceGroups_var[1].resourceGroupName)
  name: 'Company_LogAnalytics_01'
  params: {
    location: resourceGroupModule[0].outputs.RGLocation
  }
}

// Subscription Group scope
module pa1 './policy_assignments.bicep' = {
  scope: subscription(subscriptionID)
  name: 'Company_PolicyAssignment_01'
  params: {
    location: resourceGroupModule[0].outputs.RGLocation
    DCR_ResourceGroupName: resourceGroups_var[1].resourceGroupName
  }
}

module virtual_Network_with_subnet_Module './virtual_network_with_subnet.bicep' = [for virtualNetwork in virtualNetworks_var: {
  scope: resourceGroup(subscriptionID, resourceGroups_var[3].resourceGroupName)
  name: virtualNetwork.name
  params: {
    location: resourceGroupModule[0].outputs.RGLocation
    virtualNetworkName: virtualNetwork.virtualNetworkName
    addressSpace_addressPrefixes: virtualNetwork.addressSpace_addressPrefixes
    subnets: subnets_var
  }
}]

// Resource Group scope
module nic_01 './network_interface_card.bicep' = {
  scope: resourceGroup(subscriptionID, resourceGroups_var[3].resourceGroupName)
  name: 'Company_NIC_01'
  params: {
    location: resourceGroupModule[0].outputs.RGLocation
    virtualNetworkName: virtualNetworks_var[0].virtualNetworkName
    subnetName: subnets_var[0].subnetName
    networkInterfaceName01: 'LA-Test-DCR-01-NIC'
  }
}

// Resource Group scope
module virtual_Machine_01 './virtual_machine.bicep' = {
  scope: resourceGroup(subscriptionID, resourceGroups_var[2].resourceGroupName)
  name: 'Company_VirtualMachine_01'
  params: {
    location: resourceGroupModule[0].outputs.RGLocation
    virtualMachineName: 'LA-Test-DCR-01'
    networkInterfaceName: 'LA-Test-DCR-01-NIC'
    networkInterfaceResourceGroupName: resourceGroups_var[3].resourceGroupName
    adminUsername: 'marckean'
    adminPassword: 'Passw0rd2022'
    virtualMachineSize: 'Standard_B2ms'
  }
  dependsOn: [
    nic_01
  ]
}

// Resource Group scope
module PIP_module './public_IP_address.bicep' = {
  scope: resourceGroup(subscriptionID, resourceGroups_var[3].resourceGroupName)
  name: 'Company_BastionPIP_01'
  params: {
    location: resourceGroupModule[0].outputs.RGLocation
    name: 'Company_PIP'
  }
}

// Resource Group scope
module bastion_01 './bastion.bicep' = {
  scope: resourceGroup(subscriptionID, resourceGroups_var[3].resourceGroupName)
  name: 'Company_Bastion_01'
  params: {
    location: resourceGroupModule[0].outputs.RGLocation
    bastionName: 'Company_Bastion'
    virtualNetworkName: virtualNetworks_var[0].virtualNetworkName
    azureBastionPublicIpName: PIP_module.name
  }
}
