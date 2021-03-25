<#
.SYNOPSIS
Removes the username and password APIM Identity.
Removes the default Echo API and Starter/Unlimited Products.
With switch PublishApimDeveloperPortal, provisions and publishes the environments' APIM Developer portals with default styling.

.DESCRIPTION
Removes the username and password APIM Identity.
With switch PublishApimDeveloperPortal, provisions and publishes the environments' APIM Developer portals with default styling.
It is designed to be ran by an Azure CLI task with Script Type Powershell Core on a deployment agent.
If release with source alias for https://github.com/Azure/api-management-developer-portal/ is api-management-developer-portal,
working directory for Azure CLI task is set to $(System.DefaultWorkingDirectory)/api-management-developer-portal/scripts.v3

.PARAMETER EnvironmentNames
A string array of environments in a subscription. For example:
"AT,TEST"

.PARAMETER PublishApimDeveloperPortal
Switch for provisioning and publishing the developer portal

.PARAMETER ApimDeveloperPortalCustomDomainSuffix
Suffix of the APIM Developer Portal custom domain, mandatory if switch PublishApimDeveloperPortal is used

#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("DTA", "AT", "TEST", "TEST2", "DEMO", "PP", "PRD", "MO")]
    [string[]]$EnvironmentNames,
    [Parameter(ParameterSetName = 'PublishApimDeveloperPortal')]
    [switch]$PublishApimDeveloperPortal,
    [Parameter(ParameterSetName = 'PublishApimDeveloperPortal', Mandatory = $true)]
    [string]$ApimDeveloperPortalCustomDomainSuffix
)

$AzureSubscriptionId = (az account show | ConvertFrom-Json).id

if ($PublishApimDeveloperPortal) {
    Copy-Item -Path ./media -Destination ./../dist/snapshot/media
    Copy-Item -Path ./media/* -Destination ./../dist/snapshot/media
    Copy-Item -Path ./data.json -Destination ./../dist/snapshot
    Get-ChildItem -Path ./../dist/snapshot/media
    Get-ChildItem -Path ./../dist/snapshot
}

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

    # --- Remove default Echo API
    $RemoveEchoApiParameters =
    "--method", "delete",
    "--uri", "https://management.azure.com/subscriptions/$($AzureSubscriptionId)/resourceGroups/$($ApimResourceGroupName)/providers/Microsoft.ApiManagement/service/$($ApimName)/apis/echo-api?api-version=2019-12-01"
    az rest @RemoveEchoApiParameters

    function Remove-ApimProduct {
        param (
            #Default APIM Product
            [Parameter(Mandatory = $true)]
            [ValidateSet("starter", "unlimited")]
            [string]$Product
        )

        # --- Get subscription of Product
        $GetProductSubscriptionParameters =
        "--method", "get",
        "--uri", "https://management.azure.com/subscriptions/$($AzureSubscriptionId)/resourceGroups/$($ApimResourceGroupName)/providers/Microsoft.ApiManagement/service/$($ApimName)/products/$($Product)/subscriptions?api-version=2019-12-01"
        $GetProductSubscriptionResponse = az rest @GetProductSubscriptionParameters

        if ($GetProductSubscriptionResponse) {
            # --- Remove subscription of Product
            $ProductSubscriptionId = ($GetProductSubscriptionResponse | ConvertFrom-Json).value[0].name
            $RemoveProductSubscriptionParameters =
            "--method", "delete",
            "--uri", "https://management.azure.com/subscriptions/$($AzureSubscriptionId)/resourceGroups/$($ApimResourceGroupName)/providers/Microsoft.ApiManagement/service/$($ApimName)/subscriptions/$($ProductSubscriptionId)?api-version=2019-12-01"
            az rest @RemoveProductSubscriptionParameters
        }

        # --- Remove Product
        $RemoveProductParameters =
        "--method", "delete",
        "--uri", "https://management.azure.com/subscriptions/$($AzureSubscriptionId)/resourceGroups/$($ApimResourceGroupName)/providers/Microsoft.ApiManagement/service/$($ApimName)/products/$($Product)?api-version=2019-12-01"
        az rest @RemoveProductParameters
    }

    # --- Remove default APIM Products
    Remove-ApimProduct -Product "starter"
    Remove-ApimProduct -Product "unlimited"

    if ($PublishApimDeveloperPortal) {
        # --- Provision APIM developer portal
        Write-Verbose "Provisioning $($ApimName)"
        node ./generate --subscriptionId $AzureSubscriptionId --resourceGroupName $ApimResourceGroupName --serviceName $ApimName

        # --- Create APIM Shared Access Token
        $TimeInFiveMinutes = (Get-Date).ToUniversalTime().AddMinutes(5).Tostring("o")
        $SharedAcessSignatureRequestParameters =
        "--method", "post",
        "--uri", "https://management.azure.com/subscriptions/$($AzureSubscriptionId)/resourceGroups/$($ApimResourceGroupName)/providers/Microsoft.ApiManagement/service/$($ApimName)/users/1/token?api-version=2019-12-01",
        "--body", "{'properties': {'keyType': 'primary', 'expiry':'$($TimeInFiveMinutes)'}}",
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
        $PublishApimDeveloperPortalRequestParameters =
        "--method", "post",
        "--uri", "https://$($ApimDeveloperPortalDomain)/publish",
        "--headers", "{'Authorization': 'SharedAccessSignature $($SharedAccessSignature)', 'Access-Control-Allow-Origin': '*'}"
        Write-Verbose "Publishing $($ApimName)"
        az rest @PublishApimDeveloperPortalRequestParameters
    }
}
