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
