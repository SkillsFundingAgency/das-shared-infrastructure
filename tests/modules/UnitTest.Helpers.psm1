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
    $ENV:AKSRouteTableName = "Disabled"
    $ENV:AKSRouteTableResourceGroupName = "Disabled"
    $ENV:FirewallNsgName = "Disabled"
    $ENV:FirewallResourceGroupName = "Disabled"
    $ENV:backupManagementServiceObjectId = "fb0eac10-bda1-4410-9f8f-f4d381268d13"
    $ENV:gatewaySubnetCount = 1
    $ENV:internalAppSubnetCount = 1
    $ENV:externalAppSubnetCount = 1
    $ENV:sqlAdminPasswordSeed = "test seed"
    $ENV:DatabaseConfiguration = "{}"
    $ENV:sharedStorageAccountContainerArray = "['blob-container-name']"
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
        "ENV:AKSRouteTableName",
        "ENV:AKSRouteTableResourceGroupName",
        "ENV:FirewallNsgName",
        "ENV:FirewallResourceGroupName",
        "ENV:backupManagementServiceObjectId",
        "ENV:gatewaySubnetCount",
        "ENV:internalAppSubnetCount",
        "ENV:externalAppSubnetCount",
        "ENV:sqlAdminPasswordSeed",
        "ENV:sharedStorageAccountContainerArray"
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
