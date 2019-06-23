using module './../modules/InitializationHelper.psm1'
using module './../modules/ResourceGroupBuilder.psm1'
using module './../modules/FailoverGroupBuilder.psm1'
using module './../modules/ParametersFileBuilder.psm1'
Import-Module -Name "$PSScriptRoot/modules/UnitTest.Helpers.psm1" -Force

Describe "Initialize-SharedInfrastructureDeployment tests" -Tag "e2e" {

    BeforeAll {
        Set-MockEnvironment
    }

    AfterAll {
        Clear-MockEnvironment
    }

    Mock Get-AzContext {
        return @{
            "Account" = "test@test.com"
        }
    } -ModuleName 'InitializationHelper'

    Mock Get-AzResource {
        return @{ }
    } -ModuleName 'FailoverGroupBuilder'

    Mock Get-AzResourceGroup {
        Write-Verbose -Message "Using mock Get-AzResourceGroup"
        return @{
            "ResourceGroupName" = "test-resource-group"
            "Location"          = "westeurope"
            "ProvisioningState" = "Succeeded"
            "Tags"              = @{ }
            "ResourceId"        = "/subscriptions/7db81549-e1e7-467b-9c24-04b81630eeaa/resourceGroups/test-resource-group"
        }
    } -ModuleName 'ResourceGroupBuilder'

    Context "Pre deployment against an existing Resource Group" {

        It "Should consume environment variables and default variables where applicable and not throw an error" {
            { . $PSScriptRoot/../Initialize-SharedInfrastructureDeployment.ps1 -SubscriptionAbbreviation "DTA" -Verbose:$VerbosePreference } | Should Not Throw
            Assert-MockCalled -CommandName Get-AzContext -ModuleName InitializationHelper
            Assert-MockCalled -Commandname Get-AzResource -ModuleName FailoverGroupBuilder
            Assert-MockCalled -CommandName Get-AzResourceGroup -ModuleName ResourceGroupBuilder
        }
    }
}
