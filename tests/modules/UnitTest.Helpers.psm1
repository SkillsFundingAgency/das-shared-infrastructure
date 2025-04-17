function Set-MockEnvironment {
    $ENV:isTest = $true
    $ENV:environmentNames = "['DTA']"
    $ENV:resourceEnvironmentName = "DTA"
    $ENV:serviceName = "shared"
    $ENV:threatDetectionEmailAddress = "test@test.com"
    $ENV:sqlServerActiveDirectoryAdminLogin = "test@test.com"
    $ENV:keyVaultKeySecretCertificateAccessObjectId = "fb0eac10-bda1-4410-9f8f-f4d381268d13"
    $ENV:keyVaultGetAccessObjectIds = "['fb0eac10-bda1-4410-9f8f-f4d381268d13']"
    $ENV:keyVaultGetListAccessObjectIds = "['fb0eac10-bda1-4410-9f8f-f4d381268d13']"
    $ENV:sqlServerActiveDirectoryAdminObjectId = "fb0eac10-bda1-4410-9f8f-f4d381268d13"
    $ENV:microsoftAzureWebsitesRPObjectId = "fb0eac10-bda1-4410-9f8f-f4d381268d13"
    $ENV:firewallsNsgName = "Disabled"
    $ENV:backupManagementServiceObjectId = "fb0eac10-bda1-4410-9f8f-f4d381268d13"
    $ENV:virtualNetworkDeploy = "Disabled"
    $ENV:gatewaySubnetCount = 1
    $ENV:frontendSubnetCount = 1
    $ENV:backendSubnetCount = 1
    $ENV:sharedWorkerSubnetCount = 1
    $ENV:sqlAdminPasswordSeed = "test seed"
    $ENV:DatabaseConfiguration = "{}"
    $ENV:backendAppServicePlanSkus = "[]"
    $ENV:frontendAppServicePlanSkus = "[]"
    $ENV:sharedStorageAccountContainerArray = "['blob-container-name']"
    $ENV:keyVaultAllowedIpAddressesList = "['111.1.1.1/32']"
    $ENV:keyVaultAllowedSubnetsList = "[]"
    $ENV:logAnalyticsWorkspaceName = "oms"
    $ENV:logAnalyticsWorkspaceSku = "PerGB2018"
    $ENV:logAnalyticsWorkspaceDataRetentionDays = 31
    $ENV:actionGroupName = "das-dta-pl-algr"
    $ENV:actionGroupResourceGroupName = "das-dta-pl-algr"
    $ENV:databasesToExcludeFrom90PercentAlert = "das-prd-example-db"
    $ENV:databasesToIncludeIn100PercentAlert = "das-prd-example-db"
    $ENV:gatewaySubnetName = "subnet"
    $ENV:products = "['faa']"
    $ENV:deployPrivateLinkedScopedResource = false
    $ENV:routeTableRoutes = "{}"
}

function Clear-MockEnvironment {
    $ErrorActionPreference = "SilentlyContinue"
    Remove-Item -Path @(
        "ENV:isTest",
        "ENV:environmentNames",
        "ENV:resourceEnvironmentName",
        "ENV:serviceName",
        "ENV:threatDetectionEmailAddress",
        "ENV:sqlServerActiveDirectoryAdminLogin",
        "ENV:keyVaultKeySecretCertificateAccessObjectId",
        "ENV:keyVaultGetAccessObjectIds",
        "ENV:keyVaultGetListAccessObjectIds",
        "ENV:sqlServerActiveDirectoryAdminObjectId",
        "ENV:microsoftAzureWebsitesRPObjectId",
        "ENV:firewallsNsgName",
        "ENV:backupManagementServiceObjectId",
        "ENV:virtualNetworkDeploy"
        "ENV:gatewaySubnetCount",
        "ENV:frontendSubnetCount",
        "ENV:backendSubnetCount",
        "ENV:sharedWorkerSubnetCount",
        "ENV:sqlAdminPasswordSeed",
        "ENV:backendAppServicePlanSkus",
        "ENV:frontendAppServicePlanSkus",
        "ENV:sharedStorageAccountContainerArray",
        "ENV:keyVaultAllowedIpAddressesList",
        "ENV:keyVaultAllowedSubnetsList",
        "ENV:logAnalyticsWorkspaceName",
        "ENV:logAnalyticsWorkspaceSku",
        "ENV:logAnalyticsWorkspaceDataRetentionDays",
        "ENV:products",
        "ENV:routeTableRoutes",
        "ENV:actionGroupName",
        "ENV:actionGroupResourceGroupName"
        "ENV:databasesToExcludeFrom90PercentAlert"
        "ENV:databasesToIncludeIn100PercentAlert"
        "ENV:gatewaySubnetName"
    ) -Force
}

function Assert-ParameterValuesAreEqual {

    Param (
        [String[]]$EnvironmentVariableNames,
        [Hashtable]$ParametersObject
    )
    $EnvironmentVariableNames | ForEach-Object {
        $EnvValue = (Get-Item -Path ENV:$_).Value
        $ParameterValue = $ParametersObject.Get_Item($_)
        $EnvValue | Should Be $ParameterValue.Value
    }
}

Export-ModuleMember -Function @(
    "Set-MockEnvironment",
    "Clear-MockEnvironment",
    "Assert-ParameterValuesAreEqual"
)
