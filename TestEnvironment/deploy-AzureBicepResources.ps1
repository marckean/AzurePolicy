param (
    $ManagementGroupId = "8efecb12-cbaa-4612-b850-e6a68c14d336",
    $location = "australiaeast"
)

New-AzManagementGroupDeployment -Location $location -TemplateFile '.\TestEnvironment\main.bicep' -ManagementGroupId $ManagementGroupId

#az deployment mg create --location $location --management-group-id $ManagementGroupId --template-file 'C:\Users\makean\Documents\Github\AzureBicep\main.bicep' --verbose

