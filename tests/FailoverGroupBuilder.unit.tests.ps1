using module './../modules/FailoverGroupBuilder.psm1'

InModuleScope FailoverGroupBuilder{

    Mock Write-Host {
        return $null
    }

    Describe "[FailoverGroupBuilder] CreateFailoverGroupConfig() tests" {

        $MockParsedEnvironmentNames = @("MOCK")
        $MockResourceGroupName = "mock-resource-group"
        $MockSqlServerNameWestEurope = "mock-sql-servers-we"
        $MockSqlServerNameNorthEurope = "mock-sql-servers-ne"

        Mock Get-AzResource {
            return @{
                "Name"              = $MockSqlServerNameWestEurope
                "ResourceGroupName" = $MockResourceGroupName
                "ResourceType"      = "Microsoft.Sql/servers"
                "ResourceId"        = "/subscriptions/7db81549-e1e7-467b-9c24-04b81630eeaa/resourceGroups/$MockResourceGroupName/providers/Microsoft.Sql/servers/$MockSqlServerNameWestEurope"
            }
        }

        Mock Get-AzSqlDatabase {
            return @(
                @{
                    "ResourceId" = "/subscriptions/7db81549-e1e7-467b-9c24-04b81630eeaa/resourceGroups/$MockResourceGroupName/providers/Microsoft.Sql/servers/$MockSqlServerNameWestEurope/databases/db0"
                },
                @{
                    "ResourceId" = "/subscriptions/7db81549-e1e7-467b-9c24-04b81630eeaa/resourceGroups/$MockResourceGroupName/providers/Microsoft.Sql/servers/$MockSqlServerNameWestEurope/databases/db1"
                },
                @{
                    "ResourceId" = "/subscriptions/7db81549-e1e7-467b-9c24-04b81630eeaa/resourceGroups/$MockResourceGroupName/providers/Microsoft.Sql/servers/$MockSqlServerNameWestEurope/databases/db2"
                }
            )
        }

        $FailoverGroupBuilder = [FailoverGroupBuilder]::New()

        Context "When there are no sql servers in the environment" {

            Mock Get-AzResource {
                return $null
            }

            $MockDatabaseConfiguration = $FailoverGroupBuilder.CreateFailoverGroupConfig($MockParsedEnvironmentNames)

            It "Should return an object that has a property matching the environment name passed" {
                ($MockDatabaseConfiguration | ConvertFrom-Json).PSObject.Properties.Name | Should Contain "Mock"
                Assert-MockCalled -CommandName Get-AzResource
            }

            It "Should return an object with an empty array for each environment that was passed" {
                ($MockDatabaseConfiguration | ConvertFrom-Json).MOCK.DatbaaseResourceId.Count | Should Be 0
                Assert-MockCalled -CommandName Get-AzResource
            }

        }


        Context "When there are no databases in the environment and only one sql server" {

            $MockDatabaseConfiguration = $FailoverGroupBuilder.CreateFailoverGroupConfig($MockParsedEnvironmentNames)

            It "Should return an object with an empty array for each environment that was passed" {
                ($MockDatabaseConfiguration | ConvertFrom-Json).PSObject.Properties.Name | Should Contain "Mock"
                Assert-MockCalled -CommandName Get-AzResource
            }

        }

        Context "When there is one sql server that contains datbases" {

            $MockDatabaseConfiguration = $FailoverGroupBuilder.CreateFailoverGroupConfig($MockParsedEnvironmentNames)

            It "Should return a json string that can be succesfully deserialized" {
                {($MockDatabaseConfiguration | ConvertFrom-Json)} | Should Not Throw
                Assert-MockCalled -CommandName Get-AzResource
                Assert-MockCalled -CommandName Get-AzSqlDatabase
            }

            It "Should return an object that has properties that match the environment names passed" {
                ($MockDatabaseConfiguration | ConvertFrom-Json).PSObject.Properties.Name | Should Contain "MOCK"
                Assert-MockCalled -CommandName Get-AzResource
                Assert-MockCalled -CommandName Get-AzSqlDatabase
            }

            It "Should return a property that contains an array of database resourceIds and match the number of databases found in the environment" {
                ($MockDatabaseConfiguration | ConvertFrom-Json).MOCK.DatabaseResourceIds.Count | Should Be 3
                Assert-MockCalled -CommandName Get-AzResource
                Assert-MockCalled -CommandName Get-AzSqlDatabase
            }

            It "Should return a property that contains an array of valid database resourceIds" {
                ($MockDatabaseConfiguration | ConvertFrom-Json).MOCK.DatabaseResourceIds[0] | Should Be "/subscriptions/7db81549-e1e7-467b-9c24-04b81630eeaa/resourceGroups/$MockResourceGroupName/providers/Microsoft.Sql/servers/$MockSqlServerNameWestEurope/databases/db0"
                Assert-MockCalled -CommandName Get-AzResource
                Assert-MockCalled -CommandName Get-AzSqlDatabase
            }
        }

        Context "When there are two sql servers in a failover group" {

            Mock Get-AzResource {
                Write-Output @(
                    [PSCustomObject]@{
                        "Name"              = $MockSqlServerNameWestEurope
                        "ResourceGroupName" = $MockResourceGroupName
                        "ResourceType"      = "Microsoft.Sql/servers"
                        "ResourceId"        = "/subscriptions/7db81549-e1e7-467b-9c24-04b81630eeaa/resourceGroups/$MockResourceGroupName/providers/Microsoft.Sql/servers/$MockSqlServerNameWestEurope"
                    },
                    [PSCustomObject]@{
                        "Name"              = $MockSqlServerNameWestEurope
                        "ResourceGroupName" = $MockResourceGroupName
                        "ResourceType"      = "Microsoft.Sql/servers"
                        "ResourceId"        = "/subscriptions/7db81549-e1e7-467b-9c24-04b81630eeaa/resourceGroups/$MockResourceGroupName/providers/Microsoft.Sql/servers/$MockSqlServerNameWestEurope"
                    }
                )
            }

            Mock Get-AzSqlDatabaseFailoverGroup {
                return @{
                    "ReplicationRole" = "Primary"
                }
            } -ParameterFilter {$ServerName -eq $MockSqlServerNameWestEurope}

            Mock Get-AzSqlDatabaseFailoverGroup {
                return @{
                    "ReplicationRole" = "Secondary"
                }
            } -ParameterFilter {$ServerName -eq $MockSqlServerNameNorthEurope}

            $MockDatabaseConfiguration = $FailoverGroupBuilder.CreateFailoverGroupConfig($MockParsedEnvironmentNames)

            It "Should return a json string that can be succesfully deserialized" {
                {($MockDatabaseConfiguration | ConvertFrom-Json)} | Should Not Throw
                Assert-MockCalled -CommandName Get-AzResource
                Assert-MockCalled -CommandName Get-AzSqlDatabaseFailoverGroup
                Assert-MockCalled -CommandName Get-AzSqlDatabase

            }
            It "Should return a property that contains an array of database resourceIds and match the number of databases found in the environment" {
                ($MockDatabaseConfiguration | ConvertFrom-Json).MOCK.DatabaseResourceIds.Count | Should Be 3
                Assert-MockCalled -CommandName Get-AzResource
                Assert-MockCalled -CommandName Get-AzSqlDatabase
            }

            It "Should return a property that contains an array of valid database resourceIds" {
                ($MockDatabaseConfiguration | ConvertFrom-Json).MOCK.DatabaseResourceIds[0] | Should Be "/subscriptions/7db81549-e1e7-467b-9c24-04b81630eeaa/resourceGroups/$MockResourceGroupName/providers/Microsoft.Sql/servers/$MockSqlServerNameWestEurope/databases/db0"
                Assert-MockCalled -CommandName Get-AzResource
                Assert-MockCalled -CommandName Get-AzSqlDatabase
            }

        }
    }
}
