[CmdletBinding()]
Param(
    [Parameter(Mandatory = $false)]
    [ValidateSet("DTA")]
    [String]$SubscriptionAbbreviation = "DTA",
    [Parameter(Mandatory = $false)]
    [ValidateSet("DTA")]
    [String[]]$EnvironmentNames = "DTA"
)

$ManagementResourceGroupName = "das-$($SubscriptionAbbreviation)-mgmt-rg"
$ResourceGroupList = [System.Collections.ArrayList]::new(@($ManagementResourceGroupName.ToLower()))
$ResourceGroupList.AddRange(@($EnvironmentNames | ForEach-Object { "das-$($_)-shared-rg".ToLower() }))

$KeyVaultList = [System.Collections.ArrayList]::new(@())
$KeyVaultList.AddRange(@($EnvironmentNames | ForEach-Object { Get-AzKeyVault -VaultName ("das-$($_)-shared-kv".ToLower()) }))

Write-Host "Cleaning up $($ResourceGroupList.Count) resource group(s)"
$ResourceGroupList | ForEach-Object {
    try {
        Write-Host "    -> $_"
        $null = Remove-AzResourceGroup -Name $_ -Force
    }
    catch {
        Write-Warning -Message "Failed to cleanup resource group $_"
    }
}

Write-Host "Hard deleting $($KeyVaultList.Count) key vault(s)"
$KeyVaultList | ForEach-Object {
    try {
        Write-Host "    -> $($_.VaultName)"
        $null = Remove-AzKeyVault -VaultName $_.VaultName -Location $_.Location -InRemovedState -Force
    }
    catch {
        Write-Warning -Message "Failed to hard delete key vault $($_.VaultName)"
    }
}
