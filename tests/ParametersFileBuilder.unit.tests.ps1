using module './../modules/ParametersFileBuilder.psm1'
Import-Module -Name "$PSScriptRoot/modules/UnitTest.Helpers.psm1" -Force
InModuleScope ParametersFileBuilder {

    Mock Write-Host {
        return $null
    }

    $MockTemplateFilePath = "$PSScriptRoot/resources/mock.template.json"
    $MockTemplateParametersFilePath = "TestDrive:\mock.parameters.json"
    [PSCustomObject]$MockTemplateFileObject = Get-Content -Path $MockTemplateFilePath -Raw | ConvertFrom-Json

    $ParametersFileBuilder = [ParametersFileBuilder]::New()


    Describe "[ParametersFileBuilder] CreateParametersFileConfig() tests" {

        BeforeAll {
            Set-MockEnvironment
        }

        AfterAll {
            Clear-MockEnvironment
        }

        $MockParametersFileConfig = $ParametersFileBuilder.CreateParametersFileConfig($MockTemplateFilePath)

        Context "When passed a valid arm template" {

            It "Should succesfully return a PSCustomObject" {
                $MockParametersFileConfig.GetType().FullName | Should Be "System.Management.Automation.PSCustomObject"
            }

            It "Should return the same parmeters as the original arm template" {
                $TemplateFileParameterNames = $MockTemplateFileObject.Parameters.PSObject.Properties.Name | Sort-Object
                $ParametersFileParameterNames = $MockParametersFileConfig.Parameters.Keys | Sort-Object
                $TemplateFileParameterNames | Should Be $ParametersFileParameterNames
            }

            It "Should return values that match the given environment variables" {

                $EnvironmentVariableNames = @(
                    "backupManagementServiceObjectId",
                    "gatewaySubnetCount",
                    "frontendSubnetCount",
                    "backendSubnetCount",
                    "sqlAdminPasswordSeed"
                )
                Assert-ParameterValuesAreEqual -EnvironmentVariableNames $EnvironmentVariableNames -ParametersObject $MockParametersFileConfig.Parameters
            }
        }

        Context "When passed an invalid arm template" {

            It "Should throw an exception" {
                {$MockParametersFileConfig.CreateParametersFileConfig($null)} | Should Throw
            }
        }

    }

    Describe "[ParametersFileBuilder] Save() tests" {
        BeforeAll {
            Set-MockEnvironment
        }

        AfterAll {
            Clear-MockEnvironment
        }

        $MockParametersFileConfig = $ParametersFileBuilder.CreateParametersFileConfig($MockTemplateFilePath)
        $ParametersFileBuilder.Save($MockParametersFileConfig, $MockTemplateParametersFilePath)

        Context "When passed a valid parmaeters configuration object and destination path" {

            It "Should succesfully save the config to a file" {
                Test-Path -Path $MockTemplateParametersFilePath | Should BeTrue
            }

            It "Should create avfile that can be deserialized" {
                {Get-Content -Path $MockTemplateParametersFilePath -Raw | ConvertFrom-Json} | Should Not Throw
            }

            It "Should create a file that contains the same pararameter names as the config object" {
                $ParametersFileObjectParameterNames = $MockParametersFileConfig.Parameters.Keys | Sort-Object
                $TemplateParameterFileParameterNames = (Get-Content -Path $MockTemplateParametersFilePath -Raw | ConvertFrom-Json).Parameters.PSObject.Properties.Name | Sort-Object
                $TemplateParameterFileParameterNames | Should Be $ParametersFileObjectParameterNames
            }
        }
    }
}
