targetScope = 'managementGroup'

// Resource Groups
var resourceGroups_var = [
  {
    name: 'DCR_RG'
    location: 'australiaeast'
    resourceGroupName: 'Company_Tier1'
  }
]


// Tenant
var subscriptionID = '7ac51792-8ea1-4ea8-be56-eb515e42aadf'


//https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/deploy-to-management-group?tabs=azure-cli

// Subscription scope
module resourceGroupModule 'resource-group.bicep' = [for RG in resourceGroups_var: {
  name: RG.name
  scope: subscription(subscriptionID)
  params: {
    location: RG.location
    RG_name: RG.resourceGroupName
  }
}]

// Resource Group scope
module la1 'log-analytics.bicep' = {
  scope: resourceGroup(subscriptionID, resourceGroups_var[0].resourceGroupName)
  name: 'Company_LogAnalytics_01'
  params: {
    location: resourceGroupModule[0].outputs.RGLocation
  }
}

