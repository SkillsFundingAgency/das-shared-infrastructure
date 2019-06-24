using module './../modules/ResourceGroupBuilder.psm1'

InModuleScope ResourceGroupBuilder {

    Mock Write-Host {
        return $null
    }

    Describe "[ResourceGroupBuilder] CreateResourceGroups tests" {

        Mock Get-AzResourceGroup {
            return @{}
        } -Verifiable

        Mock Set-AzResourceGroup {
            return @{}
        } -Verifiable

        Mock New-AzResourceGroup {
            return @{}
        }

        $ResourceGroupBuilder = [ResourceGroupBuilder]::New()

        $MockSubscriptionAbbreviation = "MOCK"
        $MockParsedEnvironmentNames = @("MOCK")
        $MockLocation = "West Europe"
        $MockTags = @{
            Environment        = "TestEnvironment"
            'Parent Business'  = "TestParentBusiness"
            'Service Offering' = "TestServiceOffering"
        }

        $MockManagementResourceGroupName = "das-mock-mgmt-rg"
        $MockEnvironmentResourceGroupName = "das-mock-shared-rg"

        Context "When existing resource groups do not exist" {

            Mock Get-AzResourceGroup {
                return @{
                    "ResourceGroupName" = "das-mock-mgmt-rg"
                    "Location"          = "westeurope"
                    "ProvisioningState" = "Succeeded"
                    "Tags"              = $MockTags
                    "ResourceId"        = "/subscriptions/7db81549-e1e7-467b-9c24-04b81630eeaa/resourceGroups/test-resource-group"
                }
            } -Verifiable

            $MockResourceGroups = $ResourceGroupBuilder.CreateResourceGroups($MockSubscriptionAbbreviation, $MockParsedEnvironmentNames, $MockLocation, $MockTags)

            It "Should create resource groups and return an array of names" {
                $MockResourceGroups.Count | Should BeGreaterThan 0
                Assert-MockCalled -CommandName Get-AzResourceGroup
            }

            It "Should return a management resource group [$MockManagementResourceGroupName]" {
                $MockResourceGroups | Should Contain $MockManagementResourceGroupName
                Assert-MockCalled -CommandName Get-AzResourceGroup
            }

            It "Should return an environment resource group [$MockEnvironmentResourceGroupName]" {
                $MockResourceGroups | Should Contain $MockEnvironmentResourceGroupName
                Assert-MockCalled -CommandName Get-AzResourceGroup
            }

        }

        Context "When existing resource groups exist with the correct tags" {

            Mock Get-AzResourceGroup {
                return @{
                    "ResourceGroupName" = "das-mock-mgmt-rg"
                    "Location"          = "westeurope"
                    "ProvisioningState" = "Succeeded"
                    "Tags"              = $Tags
                    "ResourceId"        = "/subscriptions/7db81549-e1e7-467b-9c24-04b81630eeaa/resourceGroups/test-resource-group"
                }
            } -Verifiable

            $MockResourceGroups = $ResourceGroupBuilder.CreateResourceGroups($MockSubscriptionAbbreviation, $MockParsedEnvironmentNames, $MockLocation, $MockTags)

            It "Should not attempt to create a new resource group" {
                Assert-MockCalled -CommandName New-AzResourceGroup -Times 0
            }

            It "Should not attempt to set any properties on the resource group" {
                Assert-MockCalled -CommandName Set-AzResourceGroup -Times 0
            }

            It "Should return a management resource group [$MockManagementResourceGroupName]" {
                $MockResourceGroups | Should Contain $MockManagementResourceGroupName
            }

            It "Should return an environment resource group [$MockEnvironmentResourceGroupName]" {
                $MockResourceGroups | Should Contain $MockEnvironmentResourceGroupName
            }
        }

        Context "When existing resource groups exist with incorrect tags" {

            Mock Get-AzResourceGroup {
                return @{
                    "ResourceGroupName" = "das-mock-mgmt-rg"
                    "Location"          = "westeurope"
                    "ProvisioningState" = "Succeeded"
                    "Tags"              = @{
                        Environment        = "WrongTag"
                        'Parent Business'  = "WrongTag"
                        'Service Offering' = "WrongTag"
                    }
                    "ResourceId"        = "/subscriptions/7db81549-e1e7-467b-9c24-04b81630eeaa/resourceGroups/test-resource-group"
                }
            } -Verifiable

            $MockResourceGroups = $ResourceGroupBuilder.CreateResourceGroups($MockSubscriptionAbbreviation, $MockParsedEnvironmentNames, $MockLocation, $MockTags)

            It "Should not attempt to create a new resource group" {
                Assert-MockCalled -CommandName New-AzResourceGroup -Times 0
            }

            It "Should attempt to set properties on the resource group" {
                Assert-MockCalled -CommandName Set-AzResourceGroup -Times 1
            }

            It "Should return a management resource group [$MockManagementResourceGroupName]" {
                $MockResourceGroups | Should Contain $MockManagementResourceGroupName
            }

            It "Should return an environment resource group [$MockEnvironmentResourceGroupName]" {
                $MockResourceGroups | Should Contain $MockEnvironmentResourceGroupName
            }
        }
    }
}
