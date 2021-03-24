<#
.SYNOPSIS
Removes the username and password APIM Identity

.DESCRIPTION
Removes the username and password APIM Identity
By removing the username and password APIM Identity,
users are unable to sign up and create a username/password account on the APIM developer portal.

.PARAMETER EnvironmentNames
A string array of environments in a subscription. For example:
"AT,TEST"

#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("DTA", "AT", "TEST", "TEST2", "DEMO", "PP", "PRD", "MO")]
    [string[]]$EnvironmentNames
)

$AzureSubscriptionId = (az account show | ConvertFrom-Json).id

foreach ($EnvironmentName in $EnvironmentNames) {

    $ApimResourceGroupName = "das-$($EnvironmentName)-apim-rg".ToLower()
    $ApimName = "das-$($EnvironmentName)-shared-apim".ToLower()

    # --- Remove Username and password APIM Identity
    $RemoveUsernamePasswordApimIdentityParameters =
    "--method", "patch",
    "--uri", "https://management.azure.com/subscriptions/$($AzureSubscriptionId)/resourceGroups/$($ApimResourceGroupName)/providers/Microsoft.ApiManagement/service/$($ApimName)/portalsettings/signup?api-version=2019-12-01",
    "--body", "{'properties': {'enabled': 'false', 'termsOfService': {'enabled': 'false', 'consentRequired': 'false'}}}",
    "--headers", "{'Content-Type':'application/json'}"

    az rest @RemoveUsernamePasswordApimIdentityParameters
}
