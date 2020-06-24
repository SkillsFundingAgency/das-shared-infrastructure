[CmdletBinding()]
Param(
    [Parameter(Mandatory = $false)]
    [String]$SubscriptionAbbreviation = "DTA",
    [Parameter(Mandatory = $false)]
    [String[]]$EnvironmentNames = "DTA"
)

$ManagementResourceGroupName = "das-$($SubscriptionAbbreviation)-mgmt-rg"
$ResourceGroupList = [System.Collections.ArrayList]::new(@($ManagementResourceGroupName.ToLower()))
$ResourceGroupList.AddRange(@($EnvironmentNames | ForEach-Object { "das-$($_)-apim-rg".ToLower() }))
$ResourceGroupList.AddRange(@($EnvironmentNames | ForEach-Object { "das-$($_)-shared-rg".ToLower() }))

Write-Host "Cleaning up $($ResourceGroupList.Count) resource group(s)"
$ResourceGroupList | ForEach-Object {
    try {
        Write-Host "    -> $_"
        $null = Remove-AzResourceGroup -Name $_ -Force
    } catch {
        Write-Warning -Message "Failed to cleanup resource group $_"
    }
}
