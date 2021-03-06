using module './../modules/InitializationHelper.psm1'

InModuleScope InitializationHelper {

    Mock Write-Host {
        return $null
    }

    Describe "[InitializationHelper] isLoggedIn() tests" {

        Context "When the client is logged in to Azure" {

            Mock Get-AzContext {
                return @{
                    "Account" = "test@test.com"
                }
            } -Verifiable

            It "Should not throw an exception when an Az context is available" {
                {[InitializationHelper]::IsLoggedIn()} | Should Not Throw
                Assert-VerifiableMock
            }
        }

        Context "When the client is not logged in to Azure" {
            Mock Get-AzContext {
                return @{
                    "Account" = $null
                }
            } -Verifiable

            It "Should throw an exception when an Az context is not available" {
                {[InitializationHelper]::IsLoggedIn()} | Should Throw
                Assert-VerifiableMock
            }
        }
    }

    Describe "[InitializationHelper] GetBuildNumber() tests" {

        Context "When the script is ran from Azure Pipelines" {

            $MockBuildNumber = "1.0.0"

            BeforeAll {
                Set-Item -Path Env:\Build_BuildNumber -Value "1.0.0"
                Set-Item -Path Env:\TF_BUILD -Value $true
            }

            AfterAll {
                Remove-Item -Path Env:\Build_BuildNumber
                Remove-Item -Path Env:\TF_BUILD
            }

            It "Should return the build number found in Build.BuildNumber" {

                [InitializationHelper]::GetBuildNumber() | Should Be $MockBuildNumber
            }
        }

        Context "When the script is ran locally" {

            It "Should return the default value set by the method" {
                [InitializationHelper]::GetBuildNumber() | Should Be "local-deployment"
            }
        }
    }

    Describe "[InitializationHelper] ParseEnvironmentNames() tests" {

        Context "When the EnvironmentNames parameter is used" {
            $MockInputObject = @{
                EnvironmentNames = @("AT", "TEST")
            }

            BeforeAll {
                Remove-Item -Path ENV:EnvironmentNames -ErrorAction SilentlyContinue
            }

            AfterAll {
                Remove-Item -Path ENV:EnvironmentNames -ErrorAction SilentlyContinue
            }

            It "Should throw if no environment names can be found" {
                {[InitializationHelper]::ParseEnvironmentNames(@{})} | Should Throw
            }

            It "Should return a json string that represents an array of EnvironmentNames" {
                $MockParsedEnvironmentNames = [InitializationHelper]::ParseEnvironmentNames($MockInputObject)
                $MockParsedEnvironmentNames | Should Contain "AT"
                $MockParsedEnvironmentNames | Should Contain "TEST"
            }

            It "Should create an environment called ENV:EnvironmentNames" {
                $null = [InitializationHelper]::ParseEnvironmentNames($MockInputObject)
                {Get-Item -Path Env:EnvironmentNames} | Should Not Throw
            }

            It "Should create an environment variable containing a json string that represents an array of EnvironmentNames" {
                $null = [InitializationHelper]::ParseEnvironmentNames($MockInputObject)
                ((Get-Item -Path Env:EnvironmentNames).Value | ConvertFrom-Json) | Should Contain "AT"
            }
        }

        Context "When the environmentNames parmaeter is not used and ENV:EnvironmentNames is null" {

            BeforeAll {
                Remove-Item -Path ENV:EnvironmentNames -ErrorAction SilentlyContinue
            }

            It "Should throw if no environment names can be found" {
                {[InitializationHelper]::ParseEnvironmentNames(@{})} | Should Throw
            }
        }

        Context "When the environmentNames parameter is not used" {

            BeforeAll {
                Remove-Item -Path ENV:EnvironmentNames -ErrorAction SilentlyContinue
            }

            AfterAll {
                Remove-Item -Path ENV:EnvironmentNames -ErrorAction SilentlyContinue
            }

            $ENV:EnvironmentNames = "['AT','TEST']"
            $MockInputObject = @{}

            It "Should try to retrieve environmentNames from ENV:EnvironmentNames" {
                {[InitializationHelper]::ParseEnvironmentNames($MockInputObject)} | Should Not Throw
            }

            It "Should create an environment variable containing a json string that represents an array of EnvironmentNames" {
                $null = [InitializationHelper]::ParseEnvironmentNames($MockInputObject)
                ((Get-Item -Path Env:EnvironmentNames).Value | ConvertFrom-Json) | Should Contain "AT"
            }

            AfterAll {
                Remove-Item -Path ENV:EnvironmentNames -ErrorAction SilentlyContinue
            }
        }
    }
}
