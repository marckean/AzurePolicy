
# Find all custom Policy Definitions with an effect of Modify
$CusModifyDefs = Get-AzPolicyDefinition | where { $_.properties.PolicyType -eq 'custom' -and $_.properties.PolicyRule.then.effect -eq 'Modify' } | select * -ExpandProperty Properties

# Get the relevant Policy Assignment to the Definition
$CusModifyAssignments = foreach ($CusModifyDef in $CusModifyDefs) {
    Get-AzPolicyAssignment | where { $_.Properties.PolicyDefinitionId -eq $CusModifyDef.PolicyDefinitionId }
}


# Get Policy Rmediation for each of the custom modify assignments
$CusModifyRemediations = foreach ($CusModifyAssignment in $CusModifyAssignments) {
    Get-AzPolicyRemediation -Filter "PolicyAssignmentId eq '$($CusModifyAssignment.PolicyAssignmentId)'" | where {$_.PolicyDefinitionReferenceId}
}


foreach($CusModifyRemediation in $CusModifyRemediations){
    Start-AzPolicyRemediation -Name
}







# Kick off an AutoRemediation Task

$CusModifyAssignments

$CusModifyDefs[0]

Get-AzPolicyDefinition | where {$_.properties.PolicyType -eq 'custom'} | select * -ExpandProperty Properties, PolicyRule

(Get-AzPolicyDefinition | where {$_.properties.PolicyType -eq 'custom'} | select * -ExpandProperty Properties).PolicyRule.then.effect

Get-AzPolicyAssignment | select * -ExpandProperty Properties


$policyAssignmentId = "/subscriptions/f0710c27-9663-4c05-19f8-1b4be01e86a5/providers/Microsoft.Authorization/policyAssignments/2deae24764b447c29af7c309"
Set-AzContext -Subscription "My Subscription"

Start-AzPolicyRemediation -PolicyAssignmentId $policyAssignmentId -Name "remediation1"


$policyAssignmentId = "/subscriptions/f0710c27-9663-4c05-19f8-1b4be01e86a5/resourceGroups/myRG/providers/Microsoft.Authorization/policyAssignments/2deae24764b447c29af7c309"
Start-AzPolicyRemediation -ResourceGroupName "myRG" -PolicyAssignmentId $policyAssignmentId -PolicyDefinitionReferenceId "0349234412441" -Name "remediation1"




$w = [PSCustomObject] @{

    Subscription_Name = $ARMsub.Name
    Resource_Name = ($RmResource).ResourceName
    Deployment_Name = ($RmResource).Properties.HardwareProfile.DeploymentName
    Computer_Name = ($RmResource).Properties.InstanceView.computerName
    Fully_Qualified_Domain_Name = ($RmResource).Properties.InstanceView.FullyQualifiedDomainName
    Resource_Type = ($RmResource).ResourceType
    OS_Type = ($RmResource).Properties.StorageProfile.OperatingSystemDisk.OperatingSystem
    OS_Publisher = ($RmResource).Properties.StorageProfile.Publisher
    OS_Offer = ($RmResource).Properties.StorageProfile.OperatingSystemDisk.SourceImageName
    OS_SKU = ($RmResource).Properties.StorageProfile.ImageReference.SKU
    VM_Size = ($RmResource).Properties.HardwareProfile.Size
    Public_IP_Addresses = ($RmResource).Properties.InstanceView.PublicIpAddresses -join ' '
    Private_IP_Address = ($RmResource).Properties.InstanceView.PrivateIpAddress
    vNetName = ($RmResource).Properties.NetworkProfile.VirtualNetwork.name
    Location = ($RmResource).Location
    Provisioning_State = ($RmResource).Properties.InstanceView.Status
    Power_State = ($RmResource).Properties.InstanceView.powerState
}
    ($RmResource).Properties
    
    $Results += $w

}