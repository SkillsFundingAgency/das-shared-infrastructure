<#
.SYNOPSIS
Provisions and publishes the environments' APIM Developer portals with default styling.

.DESCRIPTION
Provisions and publishes the environments' APIM Developer portals with default styling.
It is designed to be ran by an Azure CLI task with Script Type Powershell Core on a deployment agent.
If release with source alias for https://github.com/Azure/api-management-developer-portal/ is api-management-developer-portal,
working directory for Azure CLI task is set to $(System.DefaultWorkingDirectory)/api-management-developer-portal/scripts.v3

.PARAMETER EnvironmentNames
A string array of environments in a subscription. For example:
"AT,TEST"

#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("DTA", "AT", "TEST", "TEST2", "DEMO", "PP", "PRD", "MO")]
    [string[]]$EnvironmentNames,
    [Parameter(Mandatory = $true)]
    [ValidateSet("DTA", "AT", "TEST", "TEST2", "DEMO", "PP", "PRD", "MO")]
    [string]$ApimDeveloperPortalCustomDomainSuffix
)

$AzureSubscriptionId = (az account show | ConvertFrom-Json).id

Copy-Item -Path ./media -Destination ./../dist/snapshot/media
Copy-Item -Path ./media/* -Destination ./../dist/snapshot/media
Copy-Item -Path ./data.json -Destination ./../dist/snapshot
Get-ChildItem -Path ./../dist/snapshot/media
Get-ChildItem -Path ./../dist/snapshot

foreach ($EnvironmentName in $EnvironmentNames) {

    $ApimResourceGroupName = "das-$($EnvironmentName)-apim-rg".ToLower()
    $ApimName = "das-$($EnvironmentName)-shared-apim".ToLower()

    # --- Provision APIM developer portal
    Write-Verbose "Provisioning $($ApimName)"
    node ./generate --subscriptionId $AzureSubscriptionId --resourceGroupName $ApimResourceGroupName --serviceName $ApimName

    # --- Create APIM Shared Access Token
    $TimeInFiveMinutes = (Get-Date).ToUniversalTime().AddMinutes(5).Tostring("o")
    $SharedAcessSignatureRequestParameters =
    "--method", "post",
    "--uri", "https://management.azure.com/subscriptions/$AzureSubscriptionId/resourceGroups/$ApimResourceGroupName/providers/Microsoft.ApiManagement/service/$ApimName/users/1/token?api-version=2019-12-01",
    "--body", "{'properties': {'keyType': 'primary', 'expiry':'$TimeInFiveMinutes'}}",
    "--headers", "{'Content-Type':'application/json'}"
    $SharedAccessSignature = (az rest @SharedAcessSignatureRequestParameters | ConvertFrom-Json).value

    if ($EnvironmentName -eq "DTA") {
        $ApimDeveloperPortalDomain = "$($ApimName).developer.azure-api.net"
    }
    elseif ($EnvironmentName -eq "PRD") {
        $ApimDeveloperPortalDomain = $ApimDeveloperPortalCustomDomainSuffix
    }
    else {
        $ApimDeveloperPortalDomain = "$($EnvironmentName)-$($ApimDeveloperPortalCustomDomainSuffix)".ToLower()
    }

    # --- Publish APIM developer portal
    $PublishDeveloperPortalRequestParameters =
    "--method", "post",
    "--uri", "https://$($ApimDeveloperPortalDomain)/publish",
    "--headers", "{'Authorization': 'SharedAccessSignature $($SharedAccessSignature)', 'Access-Control-Allow-Origin': '*'}"
    Write-Verbose "Publishing $($ApimName)"
    az rest @PublishDeveloperPortalRequestParameters
}
