targetScope = 'subscription'
@description('Specifies the ID of the policy definition or policy set definition being assigned.')
param BuiltIn_PolicyDefinitionID string = '9575b8b7-78ab-4281-b53b-d3c1ace2260b' //Configure Windows machines to run Azure Monitor Agent and associate them to a Data Collection Rule
param location string = 'australiaeast'
param ManagemantGroup string = 'Test'
param DCR_ResourceGroupName string

@description('Specifies the name of the policy assignment, can be used defined or an idempotent name as the defaultValue provides.')
var policyAssignmentName01 = guid(BuiltIn_PolicyDefinitionID, subscription().displayName)
var DefMgmtGroupLoc_var = tenantResourceId('Microsoft.Management/managementGroups', ManagemantGroup)
//var Owner = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '8e3af657-a8ff-443c-a75c-2fe8c4bcb635')
var Contributor = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c')
//var Reader = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'acdd72a7-3385-48ef-bd42-f606fba81ae7')
var policyDefinitionName01 = 'Configure Windows machines to run Azure Monitor Agent and associate them to a Data Collection Rule'
var policyAssignmentDisplayName01 = 'Configure Windows machines to run Azure Monitor Agent and associate them to a Data Collection Rule'
var DcrResourceId = resourceId(DCR_ResourceGroupName, 'Microsoft.Insights/dataCollectionRules', 'AllSystemInformation')

// https://docs.microsoft.com/en-us/azure/governance/policy/assign-policy-bicep

// Policy Assignment 01

resource policyAssignment01 'Microsoft.Authorization/policyAssignments@2021-06-01' = {
    name: policyAssignmentName01
    location: location
    identity: {
        type: 'SystemAssigned'
    }
    properties: {
        displayName: policyAssignmentDisplayName01
        enforcementMode: 'Default'
        //scope: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', policyDefinitionID)
        policyDefinitionId: tenantResourceId('Microsoft.Authorization/policySetDefinitions', BuiltIn_PolicyDefinitionID)
        parameters:{
            DcrResourceId: {
                value: DcrResourceId
            }
        }
    }
}

resource roleAssignment01 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = {
    name: guid('RoleAssignment', policyAssignmentName01, uniqueString(subscription().displayName))
    properties: {
        roleDefinitionId: Contributor
        principalType: 'ServicePrincipal'
        principalId: reference(policyAssignment01.id, '2021-06-01', 'full').identity.principalId
    }
}

resource remediate_policyAssignment01 'Microsoft.PolicyInsights/remediations@2021-10-01' = {
    name: guid('Remediate', policyAssignmentName01, subscription().displayName)
    properties: {
        filters: {
            locations: [
                location
            ]
        }
        policyAssignmentId: policyAssignment01.id
        policyDefinitionReferenceId: extensionResourceId(DefMgmtGroupLoc_var, 'Microsoft.Authorization/policyDefinitions', policyDefinitionName01)
        resourceDiscoveryMode: 'ExistingNonCompliant'
        failureThreshold: {
            percentage: 1
        }
        parallelDeployments: 10
        resourceCount: 500
    }
    dependsOn: [
        roleAssignment01
    ]
}

output assignmentId string = policyAssignment01.id
