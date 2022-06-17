targetScope = 'subscription'
param policyAssignmentName string = 'audit-vm-manageddisks'
param policyDefinitionID string = '/providers/Microsoft.Authorization/policySetDefinitions/9575b8b7-78ab-4281-b53b-d3c1ace2260b' //Configure Windows machines to run Azure Monitor Agent and associate them to a Data Collection Rule
param subscriptionID string
param ResourceGroupName string

// https://docs.microsoft.com/en-us/azure/governance/policy/assign-policy-bicep

resource assignment01 'Microsoft.Authorization/policyAssignments@2021-09-01' = {
    name: policyAssignmentName
    scope: subscriptionResourceId('Microsoft.Resources/resourceGroups', resourceGroup().name)
    properties: {
        DcrResourceId: '/subscriptions/${subscriptionID}/resourceGroups/${ResourceGroupName}'
    }
}

output assignmentId string = assignment01.id


7ac51792-8ea1-4ea8-be56-eb515e42aadf Company_02/providers/Microsoft.Insights/dataCollectionRules/DCR-AllSystemInformation
