class FailoverGroupBuilder {

    FailoverGroupBuilder() {
    }

    [string] CreateFailoverGroupConfig([String]$EnvironmentNames) {

        [Hashtable]$DatabaseConfiguration = @{ }

        Write-Host "- Setting up failover group config ->"

        $EnvironmentNames | ForEach-Object {
            Write-Host "    -  Environment $_"
            Write-Host $DatabaseConfiguration

            $DatabaseConfiguration.Add(
                $_, @{"DatabaseResourceIds" = @() }
            )

            Write-Host $DatabaseConfiguration

            # --- Get all shared SQL Servers in environment
            $SqlServerResources = @(Get-AzResource -Name "das-$($_.ToLower())-shared-sql*" -ResourceType "Microsoft.Sql/servers")

            # --- If there is more than one then find the primary
            if ($SqlServerResources.Count -gt 1) {
                $SqlServer = $SqlServerResources | Where-Object {
                    $FailoverGroup = Get-AzSqlDatabaseFailoverGroup -ServerName $_.Name -ResourceGroupName $_.ResourceGroupName
                    if ($FailoverGroup -and $FailoverGroup.ReplicationRole -eq "Primary") {
                        return $_
                    }
                }
            }
            elseif ($SqlServerResources -eq 1) {
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
