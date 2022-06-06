$currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
$resourceGroup = $currentUser.Substring($currentUser.IndexOf('\') + 1) + "-testing"
$containerName = $currentUser.Substring($currentUser.IndexOf('\') + 1) + "-testing"
$storageAccountName = "20220509stgacct";
$containerUrl = "https://${storageAccountName}.blob.core.windows.net/${containerName}"

Write-Host "Current user: <${currentUser}>" -ForegroundColor Green
Write-Host "Deployment will use templates from <${containerName}> container" -ForegroundColor Green
Write-Host "Resources will be deployed to <${resourceGroup}> resource group" -ForegroundColor Green
Write-Host

Write-Host "Syncing templates..." -ForegroundColor Green
.\azcopy.exe sync '.' $containerUrl --include-pattern "*.json" --delete-destination true


$templateUri = "${containerUrl}/deploy.json"

Write-Host "`nDeploying:  ${templateUri}" -ForegroundColor Green

Test-AzResourceGroupDeployment -ResourceGroupName $resourceGroup `
    -TemplateUri $templateUri `
    -Mode Incremental `
    -Verbose

New-AzResourceGroupDeployment -ResourceGroupName $resourceGroup `
    -TemplateUri $templateUri `
    -Mode Incremental `
    -DeploymentDebugLogLevel All `
    -Verbose