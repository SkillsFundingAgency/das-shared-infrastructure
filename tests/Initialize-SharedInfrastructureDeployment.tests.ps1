using module '.\..\modules\AzureContextHelper.psm1'
using module '.\..\modules\ResourceGroupBuilder.psm1'
using module '.\..\modules\FailoverGroupBuilder.psm1'
using module '.\..\modules\ParametersFileBuilder.psm1'
Describe "Initialize-SharedInfrastructureDeployment tests" {

    $ENV:isTest = $true
    $ENV:environmentNames = "['DTA']"
    $ENV:resourceEnvironmentName = "['DTA']"
    $ENV:serviceName = "shared"
    $ENV:threatDetectionEmailAddress = "test@test.com"
    $ENV:sqlServerActiveDirectoryAdminLogin = "test@test.com"
    $ENV:keyVaultAccessObjectIds = "['fb0eac10-bda1-4410-9f8f-f4d381268d13']"
    $ENV:sqlServerActiveDirectoryAdminObjectId = "fb0eac10-bda1-4410-9f8f-f4d381268d13"
    $ENV:diskEncryptionAppRegistrationObjectId = "fb0eac10-bda1-4410-9f8f-f4d381268d13"
    $ENV:backupManagementServiceObjectId = "fb0eac10-bda1-4410-9f8f-f4d381268d13"
    $ENV:gatewaySubnetCount = 1
    $ENV:internalAppSubnetCount = 1
    $ENV:externalAppSubnetCount = 1
    $ENV:sqlAdminPasswordSeed = "test seed"

    Mock Get-AzContext {
        Write-Verbose -Message "Using mock Get-AzContext"
        return @{
            "Account" = "test@test.com"
        }
    } -ModuleName 'AzureContextHelper' -Verifiable

    Mock Get-AzResource {
        Write-Verbose -Message "Using mock Get-AzResource"
        return @{ }
    } -ModuleName 'FailoverGroupBuilder' -Verifiable

    Context "Pre deployment against an existing Resource Group" {

        Mock Get-AzResourceGroup {
            Write-Verbose -Message "Using mock Get-AzResourceGroup"
            return @{
                "ResourceGroupName" = "test-resource-group"
                "Location"          = "westeurope"
                "ProvisioningState" = "Succeeded"
                "Tags"              = @{ }
                "ResourceId"        = "/subscriptions/7db81549-e1e7-467b-9c24-04b81630eeaa/resourceGroups/test-resource-group"
            }
        } -ModuleName 'ResourceGroupBuilder' -Verifiable

        It "Should consume environment variables and default variables where applicable and now throw an error" {
            { . $PSScriptRoot\..\Initialize-SharedInfrastructureDeployment.ps1 -SubscriptionAbbreviation "DTA" -Verbose:$VerbosePreference } | Should Not Throw
            Assert-VerifiableMocks
        }
    }
}
