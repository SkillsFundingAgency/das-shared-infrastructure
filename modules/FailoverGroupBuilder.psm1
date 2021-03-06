class FailoverGroupBuilder {

    [string] CreateFailoverGroupConfig([String[]]$EnvironmentNames) {

        [Hashtable]$DatabaseConfiguration = @{ }

        Write-Host "- Setting up failover group config ->"

        $EnvironmentNames | ForEach-Object {
            $null = $DatabaseConfiguration.Add(
                $_, @{"DatabaseResourceIds" = @() }
            )

            # --- Get all shared SQL Servers in environment
            $SqlServerResources = @(Get-AzResource -Name "das-$($_.ToLower())-shared-sql*" -ResourceType "Microsoft.Sql/servers")
            # --- If there is more than one then find the primary
            if ($SqlServerResources.Count -gt 1) {
                $SqlServerResources | Where-Object {
                    $FailoverGroup = Get-AzSqlDatabaseFailoverGroup -ServerName $_.Name -ResourceGroupName $_.ResourceGroupName
                    if ($FailoverGroup -and $FailoverGroup.ReplicationRole -eq "Primary") {
                        $SqlServer = $_
                    }
                }
            }
            elseif ($SqlServerResources.Name.Count -eq 1) {
                # --- If there is only one, use that
                $SqlServer = $SqlServerResources[0]
            }
            else {
                return
            }

            # --- Get all the databases in the server that aren't master
            $Databases = Get-AzSqlDatabase -ServerName $SqlServer.Name -ResourceGroupName $SqlServer.ResourceGroupName | Where-Object { $_.DatabaseName -ne "master" }

            $DatabaseConfiguration.$_.DatabaseResourceIds = @($Databases.ResourceId)
            Write-Host "    - Adding $($Databases.Count) databases to $_ failover group"
        }

        return $DatabaseConfiguration | ConvertTo-Json
    }
}
