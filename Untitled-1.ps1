# From: https://github.com/tianderturpijn/ASC/blob/master/AzPolicy/createAzurePolicyRemediationTask.ps1
# This script will create an Azure Policy remediation task based on 
# your SubscriptionID and PolicyId

#region - Authenticate against Azure
$subscriptionId = "7ac51792-8ea1-4ea8-be56-eb515e42aadf"
$AzAccount = Add-AzAccount -SubscriptionId $subscriptionId
#endregion

#region - Creating an access token - this is only valid for a specific amount of time
$tenantId = (Get-AzSubscription -SubscriptionId $subscriptionId).TenantId
$tokenCache = $AzAccount.Context.TokenCache
$cachedTokens = $tokenCache.ReadItems() `
        | where { $_.TenantId -eq $tenantId } `
        | Sort-Object -Property ExpiresOn -Descending
$accessToken = $cachedTokens[0].AccessToken
#endregion

$baseURI = "https://management.azure.com"
$provider = "Microsoft.PolicyInsights/remediations"
$remediationName = "<yourRemediationName>"
$policyID = "Secure Trans Stg Acct"
$policyAssignmentString = "/subscriptions/" + $subscriptionID + "/providers/microsoft.authorization/policyassignments/" + $policyID
$suffixURI =  "?api-version=2018-07-01-preview"
$SubscriptionURI = $baseURI + "/subscriptions/$subscriptionID" + "/providers/" + $provider + "/" + $remediationName + $suffixURI
$uri = $SubscriptionURI


$Body = "{ `
    'properties': {
     'policyAssignmentId': '$policyAssignmentString' `
   }, `
}"

$params = @{
    ContentType = 'application/json'
    Headers = @{
        "Authorization" = "Bearer " + $accessToken
        }
    Body = $Body
    Method = 'PUT'
    URI = $uri
}

Invoke-RestMethod @params