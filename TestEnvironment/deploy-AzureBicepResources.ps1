$ManagementGroupId = "8efecb12-cbaa-4612-b850-e6a68c14d336"
$location = "australiaeast"

$TimeNow = Get-Date -Format yyyyMMdd-hhmm

# All test resources, with the NSG and NSG rules as separate
New-AzManagementGroupDeployment -Location $location -TemplateFile '.\TestEnvironment\main.bicep' -ManagementGroupId $ManagementGroupId -Name $TimeNow -Verbose

# NSG with rules included - ONLY
New-AzManagementGroupDeployment -Location $location -TemplateFile '.\TestEnvironment\main(nsg).bicep' -ManagementGroupId $ManagementGroupId -Name $TimeNow -Verbose

#az deployment mg create --location $location --management-group-id $ManagementGroupId --template-file 'C:\Users\makean\Documents\Github\AzureBicep\main.bicep' --verbose
