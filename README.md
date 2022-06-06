
# Contents of this repo

- There's a Test environment folder which includes Bicep deployment files to deploy the test resources to Azure, so that you can test Azure Policy against real Azure Resources.
  - You will need to install the **Azure CLI** as per [here](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli).
- Then the rest of this is Azure Policy itself deploying using nested templates from the parent template. 
  - `deploy.json` is the parent template
  - `/artifacts/policyAssignments.json` and `/artifacts/policyDefinitions.json` are the two child templates
  - `/artifacts/policyDefinitions.json` is deployed to the Management Group Scope. Policy Definitions live in the root Management Group.
  - `/artifacts/policyAssignments.json` is deployed to the Subscription scope. Policy Assignments live in lower levels of the hierarchy e.g. a subscription.

To deploy all of this, we are using the following [PowerShell script](https://github.com/marckean/AzurePolicy/blob/main/deploy-AzureJSONResources.ps1):

```powershell
param (
    $ManagementGroupId = "8efecb12-cbaa-4612-b850-e6a68c14d336",
    $location = "australiaeast",
    $ts_resourcegroupname = "TemplateSpecs"
)

New-AzTemplateSpec `
  -Name 'TS_policyAssignments' `
  -Version "2.0.0" `
  -ResourceGroupName $ts_resourcegroupname `
  -Location $location `
  -TemplateFile "C:\Users\makean\Documents\AzureDevOps\policy-automation\artifacts\policyAssignments.json" `
  -Force

  New-AzTemplateSpec `
  -Name 'TS_policyDefinitions' `
  -Version "2.0.0" `
  -ResourceGroupName $ts_resourcegroupname `
  -Location $location `
  -TemplateFile "C:\Users\makean\Documents\AzureDevOps\policy-automation\artifacts\policyDefinitions.json" `
  -Force

New-AzManagementGroupDeployment -Location $location -TemplateFile 'C:\Users\makean\Documents\AzureDevOps\policy-automation\deploy.json' -ManagementGroupId $ManagementGroupId -Verbose -ErrorAction Continue

```

Why we're using a PowerShell script, because the nested templates have to live somewhere. For this, we're using Template Specs in Azure.

## Deployment Scope

More on deployment scopes here:

[Resource group deployments with ARM templates](https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/deploy-to-resource-group?tabs=azure-cli)

[Subscription deployments with ARM templates](https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/deploy-to-subscription?tabs=azure-cli)

[Management group deployments with ARM templates](https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/deploy-to-management-group?tabs=azure-cli)

[Tenant deployments with ARM templates](https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/deploy-to-tenant?tabs=azure-cli)
# Policy Remediation

Policy **DeployIfNotExists** or **Modify** effect will take effect on any new or updated resources. Existing resources after they are scanned by the Policy Compliance Checker engine will need a remediation task kicked off or through code to get remediated. [From here](https://youtu.be/AVn5glYBz84?t=4279).

Policy assignments must include a 'managed identity' when assigning 'Modify' policy definitions. Please see https://aka.ms/azurepolicyremediation for usage information.

[Remediate non-compliant resources with Azure Policy](https://aka.ms/azurepolicyremediation)

Resources that are non-compliant to a **deployIfNotExists** or **modify** policy can be put into a compliant state through **Remediation**. Remediation is accomplished by instructing Azure Policy to run the deployIfNotExists effect or the modify operations of the assigned policy on your existing resources and subscriptions, whether that assignment is to a management group, a subscription, a resource group, or an individual resource. This article shows the steps needed to understand and accomplish remediation with Azure Policy.

## Enable remediation tasks

From [here](https://docs.microsoft.com/en-us/azure/governance/policy/concepts/policy-as-code#enable-remediation-tasks), if validation of the assignment meets expectations, the next step is to validate remediation. Policies that use either [deployIfNotExists](https://docs.microsoft.com/en-us/azure/governance/policy/concepts/effects#deployifnotexists) or [modify](https://docs.microsoft.com/en-us/azure/governance/policy/concepts/effects#modify) may be turned into a remediation task and correct resources from a non-compliant state.

The first step to remediating resources is to grant the policy assignment the role assignment defined in the policy definition. This role assignment gives the policy assignment managed identity enough rights to make the needed changes to make the resource compliant.

Once the policy assignment has appropriate rights, **use the Policy SDK to trigger a remediation task** against a set of resources that are known to be non-compliant. Three tests should be completed against these remediated tasks before proceeding:

- Validate that the remediation task completed successfully
- Run policy evaluation to see that policy compliance results are updated as expected
- Run an environment unit test against the resources directly to validate their properties have changed

Testing both the updated policy evaluation results and the environment directly provide confirmation that the remediation tasks changed what was expected and that the policy definition saw the compliance change as expected. 

## Policy Definition Structure

## Conditions
A condition evaluates whether a value meets certain criteria. The supported conditions are:

- `"equals": "stringValue"`
- `"notEquals": "stringValue"`
- `"like": "stringValue"`
- `"notLike": "stringValue"`
- `"match": "stringValue"`
- `"matchInsensitively": "stringValue"`
- `"notMatch": "stringValue"`
- `"notMatchInsensitively": "stringValue"`
- `"contains": "stringValue"`
- `"notContains": "stringValue"`
- `"in": ["stringValue1","stringValue2"]`
- `"notIn": ["stringValue1","stringValue2"]`
- `"containsKey": "keyName"`
- `"notContainsKey": "keyName"`
- `"less": "dateValue"` | `"less": "stringValue"` | `"less": intValue`
- `"lessOrEquals": "dateValue"` | `"lessOrEquals": "stringValue"` | `"lessOrEquals": intValue`
- `"greater": "dateValue"` | `"greater": "stringValue"` | `"greater": intValue`
- `"greaterOrEquals": "dateValue"` | `"greaterOrEquals": "stringValue"` |
  `"greaterOrEquals": intValue`
- `"exists": "bool"`


## Policy Aliases

From [here](https://docs.microsoft.com/en-us/azure/governance/policy/concepts/definition-structure#aliases) You use property aliases to access specific properties for a resource type. Aliases enable you to restrict what values or conditions are allowed for a property on a resource. Each alias maps to paths in different API versions for a given resource type. During policy evaluation, the policy engine gets the property path for that API version.

The list of aliases is always growing. To find what aliases are currently supported by Azure Policy, use one of the following methods:

```Powershell
(Get-AzPolicyAlias -NamespaceMatch 'securityRules/sourcePortRange').Aliases | convertto-csv | clip
```
To find aliases that can be used with the modify effect, use the following command in Azure PowerShell 4.6.0 or higher:

```Powershell
Get-AzPolicyAlias | Select-Object -ExpandProperty 'Aliases' | Where-Object { $_.DefaultMetadata.Attributes -eq 'Modifiable' -and $_.Name -match 'networkSecurityGroups/securityRules'}
```

## Policy Functions

Azure Policy uses functions such as `field` or `current` and within the ARM template, it would show an error `Unrecognized function name 'field'`. 

![here](./blobs/Unrecognizedfunctionname.png)

To overcome this, it's a fairly simple fix, you put a single open square bracket `[` at the beginning, as shown below. 

![here](./blobs/Unrecognizedfunctionname2.png)

## Referencing array resource properties

From [here](https://docs.microsoft.com/en-us/azure/governance/policy/how-to/author-policies-for-arrays#referencing-array-resource-properties) Aliases that use the [*] syntax represent a collection of property values selected from an array property, which is different than selecting the array property itself. In the case of `Microsoft.Test/resourceType/stringArray[*]`, it returns a collection that has all of the members of `stringArray`. As mentioned previously, a `field` condition checks that all selected resource properties meet the condition, therefore the following condition is true only if all the members of `stringArray` are equal to '"value"'.

## Enterprise Scale Landing Zone Policy Definitions

From [here](https://raw.githubusercontent.com/Azure/Enterprise-Scale/main/eslzArm/managementGroupTemplates/policyDefinitions/policies.json), this is the enterprise landing zone **Policy Definitions** which also includes **Policy Initiatives**. Some good examples in here, but also the way this template is structured, you sill notice only two resources are listed at the very bottom using the `copyIndex` function, which enumerates the index of one of the variables. 

There's the two resources which loop the through the index of the variable:

- Microsoft.Authorization/policyDefinitions
- Microsoft.Authorization/policySetDefinitions

## Author policies for array properties on Azure resources

From [here](https://docs.microsoft.com/en-us/azure/governance/policy/how-to/author-policies-for-arrays), 

Azure Resource Manager properties are commonly defined as strings and booleans. When a one-to-many relationship exists, complex properties are instead defined as arrays. In Azure Policy, arrays are used in several different ways. 

The value count expression count how many array members meet a condition. It provides a way to evaluate the same condition multiple times, using different values on each iteration. For example, the following condition checks whether the resource name matches any pattern from an array of patterns. 

```JSON
{
    "count": {
        "value": [ "test*", "dev*", "prod*" ],
        "name": "pattern",
        "where": {
            "field": "name",
            "like": "[current('pattern')]"
        }
    },
    "greater": 0
}
```

In order to evaluate the expression, Azure Policy evaluates the `where` condition three times, once for each member of `[ "test*", "dev*", "prod*" ]`, counting how many times it was evaluated to `true`. On every iteration, the value of the current array member is paired with the `pattern` index name defined by `count.name`. This value can then be referenced inside the `where` condition by calling a special template function: `current('pattern')`.

## Start a compliance scan

From [here](https://docs.microsoft.com/en-us/powershell/module/az.policyinsights/start-azpolicycompliancescan), you can run the following:

```powershell
$job = Start-AzPolicyComplianceScan -AsJob
$job | Wait-Job
```

# Managed Identities

From [here](https://docs.microsoft.com/en-us/troubleshoot/azure/active-directory/troubleshoot-adding-apps#i-want-to-delete-an-application-but-the-delete-button-is-disabled), for servicePrincipals that correspond to a managed identity. Managed identities service principals can't be deleted in the Enterprise apps blade. You need to go to the Azure resource to manage it. Learn more about [Managed Identity](https://docs.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/overview).

It isn't a problem to leave these role assignments where the security principal has been deleted. If you like, you can remove these role assignments using steps that are similar to other role assignments. For information about how to remove role assignments, see [Remove Azure role assignments](https://docs.microsoft.com/en-us/azure/role-based-access-control/role-assignments-remove).

## Role assignments with identity not found

From [here](https://docs.microsoft.com/en-us/azure/role-based-access-control/troubleshooting#role-assignments-with-identity-not-found), it might be due to a deleted security principal. If you assign a role to a security principal and then you later delete that security principal without first removing the role assignment, the security principal will be listed as Identity not found and an Unknown type.

```Powershell
Get-AzRoleAssignment | where {$_.DisplayName-eq $null}

Remove-AzRoleAssignment -ObjectId ((Get-AzRoleAssignment | where {$_.DisplayName-eq $null})[0].ObjectId) -RoleDefinitionName ((Get-AzRoleAssignment | where {$_.DisplayName-eq $null})[0].RoleDefinitionName)
```

# Deployments

- The policy effect 'details' field must contains at least one role definition Id.
- Policy assignments must include a 'managed identity' when assigning 'Modify' policy definitions. Please see https://aka.ms/azurepolicyremediation for usage information.



## Deployment of Test environment

Firstly, you'll need to install **Bicep**, so you can deploy successfully, as per [here](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/install).

You will need to install the **Azure CLI** as per [here](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli).

```powershell
param (
    $ManagementGroupId = "8efecb12-cbaa-4612-b850-e6a68c14d336",
    $location = "australiaeast",
    $ts_resourcegroupname = "TemplateSpecs"
)

New-AzManagementGroupDeployment -Location $location -TemplateFile 'C:\Users\makean\Documents\Github\AzureBicep\main.bicep' -ManagementGroupId $ManagementGroupId

```

To deploy to a resource group, use az deployment group create:

az deployment group create --resource-group <resource-group-name> --template-file <path-to-bicep>

To deploy to a subscription, use az deployment sub create:

az deployment sub create --location 'australiaeast' --template-file ./main.bicep

To deploy to a management group, use az deployment mg create:

az deployment mg create --location <location> --template-file <path-to-bicep>

To deploy to a tenant, use az deployment tenant create:

az deployment tenant create --location <location> --template-file <path-to-bicep>

Deploy Bicep to management group:
```json
az deployment sub create --location australiaeast --template-file ./main.bicep
```
Deploy Bicep to management group:
```json
az deployment mg create --location australiaeast --management-group-id '8efecb12-cbaa-4612-b850-e6a68c14d336' --template-file ./main.bicep
```
## Deployment of Azure Policy

Deploy JSON to management group. We are using nested templates in order to deploy this complete solution to Azure. Reason is, the **Policy Definitions** will be deployed to the root Management Group so they can be accessed by everything else in the hierarchy. The **Policy Assignments** will be deployed separately to child subscriptions. 

```Powershell
param (
    $ManagementGroupId = "8efecb12-cbaa-4612-b850-e6a68c14d336",
    $location = "australiaeast",
    $ts_resourcegroupname = "TemplateSpecs"
)

New-AzTemplateSpec `
  -Name 'TS_policyAssignments' `
  -Version "2.0.0" `
  -ResourceGroupName $ts_resourcegroupname `
  -Location $location `
  -TemplateFile "C:\Users\makean\Documents\AzureDevOps\policy-automation\artifacts\policyAssignments.json" `
  -Force

  New-AzTemplateSpec `
  -Name 'TS_policyDefinitions' `
  -Version "2.0.0" `
  -ResourceGroupName $ts_resourcegroupname `
  -Location $location `
  -TemplateFile "C:\Users\makean\Documents\AzureDevOps\policy-automation\artifacts\policyDefinitions.json" `
  -Force

New-AzManagementGroupDeployment -Location $location -TemplateFile 'C:\Users\makean\Documents\AzureDevOps\policy-automation\deploy.json' -ManagementGroupId $ManagementGroupId -Verbose -ErrorAction Continue

```

### Use relative path for linked templates

The **relativePath** property of Microsoft.Resources/deployments makes it easier to author linked templates. This property can be used to deploy a remote linked template at a location relative to the parent. This feature requires all template files to be staged and available at a remote URI, such as GitHub or Azure storage account. When the main template is called by using a URI from Azure PowerShell or Azure CLI, the child deployment URI is a combination of the parent and relativePath.

[Use relative path for linked templates](https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/linked-templates?tabs=azure-powershell#use-relative-path-for-linked-templates)

