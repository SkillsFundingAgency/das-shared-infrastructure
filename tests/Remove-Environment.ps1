[CmdletBinding()]
Param(
    [Parameter(Mandatory = $false)]
    [String]$SubscriptionAbbreviation = "dta",
    [Parameter(Mandatory = $false)]
    [String]$EnvironmentName = "dta"
)

$ApimResourceGroup = "das-$($EnvironmentName)-apim-rg"
$ResourceGroupList = @("das-$($SubscriptionAbbreviation)-mgmt-rg", $ApimResourceGroup, "das-$($EnvironmentName)-shared-rg")

Write-Host "Cleaning up APIM"
Remove-AzApiManagement -ResourceGroupName $ApimResourceGroup -Name "das-$($EnvironmentName)-shared-apim"

Write-Host "Cleaning up resource groups"
$ResourceGroupList | ForEach-Object {
    try {
        Write-Host "    -> $_"
        $null = Remove-AzResourceGroup -Name $_ -Force
    } catch {
        Write-Warning -Message "Failed to cleanup resource group $_"
    }
}
