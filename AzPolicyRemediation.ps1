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

# Kick off Policy Remediation Tasks
foreach($CusModifyRemediation in $CusModifyRemediations){
    Start-AzPolicyRemediation -Name $CusModifyRemediation.Name -PolicyAssignmentId $CusModifyRemediation.PolicyAssignmentId
}
