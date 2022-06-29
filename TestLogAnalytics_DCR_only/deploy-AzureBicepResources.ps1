$ManagementGroupId = "8efecb12-cbaa-4612-b850-e6a68c14d336" # this is the root Management Group ID
$location = "australiaeast"

$TimeNow = Get-Date -Format yyyyMMdd-hhmm

# All test resources, with the NSG and NSG rules as separate
New-AzManagementGroupDeployment -Location $location -TemplateFile '.\TestLogAnalytics_DCR_only\main.bicep' -ManagementGroupId $ManagementGroupId -Name $TimeNow -Verbose
