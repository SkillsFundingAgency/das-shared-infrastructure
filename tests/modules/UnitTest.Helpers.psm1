function Set-MockEnvironment {
    $ENV:isTest = $true
    $ENV:environmentNames = "['DTA']"
    $ENV:resourceEnvironmentName = "DTA"
    $ENV:serviceName = "shared"
    $ENV:threatDetectionEmailAddress = "test@test.com"
    $ENV:sqlServerActiveDirectoryAdminLogin = "test@test.com"
    $ENV:keyVaultSecretCertificateAccessObjectId = "fb0eac10-bda1-4410-9f8f-f4d381268d13"
    $ENV:keyVaultSecretAccessObjectIds = "['fb0eac10-bda1-4410-9f8f-f4d381268d13']"
    $ENV:sqlServerActiveDirectoryAdminObjectId = "fb0eac10-bda1-4410-9f8f-f4d381268d13"
    $ENV:diskEncryptionEnterpriseApplicationObjectId = "fb0eac10-bda1-4410-9f8f-f4d381268d13"
    $ENV:microsoftAzureWebsitesRPObjectId = "fb0eac10-bda1-4410-9f8f-f4d381268d13"
    $ENV:AKSEnterpriseApplicationObjectId = "Disabled"
    $ENV:firewallsNsgName = "Disabled"
    $ENV:backupManagementServiceObjectId = "fb0eac10-bda1-4410-9f8f-f4d381268d13"
    $ENV:virtualNetworkDeploy = "Disabled"
    $ENV:gatewaySubnetCount = 1
    $ENV:apimSubnetCount = 1
    $ENV:frontendSubnetCount = 1
    $ENV:backendSubnetCount = 1
    $ENV:apimEndpointSubnetCount = 1
    $ENV:sqlAdminPasswordSeed = "test seed"
    $ENV:DatabaseConfiguration = "{}"
    $ENV:sharedStorageAccountContainerArray = "['blob-container-name']"
    $ENV:logAnalyticsWorkspaceName = "oms"
    $ENV:logAnalyticsWorkspaceSku = "PerGB2018"
    $ENV:logAnalyticsWorkspaceDataRetentionDays = 31
    $ENV:customDomainHostedZone = "hosted-zone.com"
    $ENV:apimInitialDeploy = "Disabled"
    $ENV:apimSKU = "Developer"
    $ENV:apimPublisherEmail = "test@test.com"
    $ENV:apimPublisherName = "Test Publisher"
    $ENV:apimPortalKeyVaultCertificateName = "test-apim-portal-com"
    $ENV:apimGatewayKeyVaultCertificateName = "test-apim-gateway-com"
    $ENV:apimManagementKeyVaultCertificateName = "test-apim-management-com"
    $ENV:tenantPrimaryDomain = "tenant.onmicrosoft.com"
    $ENV:apimAppRegistrationClientIds = "{'DTA':'fb0eac10-bda1-4410-9f8f-f4d381268d13'}"
    $ENV:apimAppRegistrationClientSecret = "client-secret"
    $ENV:apimGroupsArray = "[]"
    $ENV:apimProductsArray = "[]"
    $ENV:apimProductsState = "notPublished"
    $ENV:actionGroupName = "das-dta-pl-algr"
    $ENV:actionGroupResourceGroupName = "das-dta-pl-algr"
    $ENV:databasesToExcludeFrom90PercentAlert = "das-prd-example-db"
    $ENV:databasesToIncludeIn100PercentAlert = "das-prd-example-db"
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
        "ENV:keyVaultSecretCertificateAccessObjectId",
        "ENV:keyVaultSecretAccessObjectIds",
        "ENV:sqlServerActiveDirectoryAdminObjectId",
        "ENV:diskEncryptionEnterpriseApplicationObjectId",
        "ENV:microsoftAzureWebsitesRPObjectId",
        "ENV:AKSEnterpriseApplicationObjectId",
        "ENV:firewallsNsgName",
        "ENV:backupManagementServiceObjectId",
        "ENV:virtualNetworkDeploy"
        "ENV:gatewaySubnetCount",
        "ENV:apimSubnetCount",
        "ENV:frontendSubnetCount",
        "ENV:backendSubnetCount",
        "ENV:apimEndpointSubnetCount",
        "ENV:sqlAdminPasswordSeed",
        "ENV:sharedStorageAccountContainerArray",
        "ENV:logAnalyticsWorkspaceName",
        "ENV:logAnalyticsWorkspaceSku",
        "ENV:logAnalyticsWorkspaceDataRetentionDays",
        "ENV:customDomainHostedZone",
        "ENV:apimInitialDeploy",
        "ENV:apimSKU",
        "ENV:apimPublisherEmail",
        "ENV:apimPublisherName",
        "ENV:apimPortalKeyVaultCertificateName",
        "ENV:apimGatewayKeyVaultCertificateName",
        "ENV:apimManagementKeyVaultCertificateName",
        "ENV:tenantPrimaryDomain",
        "ENV:apimAppRegistrationClientIds",
        "ENV:apimAppRegistrationClientSecret",
        "ENV:apimGroupsArray",
        "ENV:apimProductsArray",
        "ENV:apimProductsState",
        "ENV:actionGroupName",
        "ENV:actionGroupResourceGroupName"
        "ENV:databasesToExcludeFrom90PercentAlert"
        "ENV:databasesToIncludeIn100PercentAlert"
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
