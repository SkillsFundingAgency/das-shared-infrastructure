[CmdletBinding()]
Param(
    [Parameter(Mandatory = $false)]
    [String]$SubscriptionAbbreviation = "dta",
    [Parameter(Mandatory = $false)]
    [String]$EnvironmentName = "dta"
)

$ResourceGroupList = @("das-$($SubscriptionAbbreviation)-mgmt-rg", "das-$($EnvironmentName)-shared-rg")

Write-Host "Cleaning up resource groups"
$ResourceGroupList | ForEach-Object {
    try {
        Write-Host "    -> $_"
        $null = Remove-AzResourceGroup -Name $_ -Force
    } catch {
        Write-Warning -Message "Failed to cleanup resource group $_"
    }
}
