[CmdletBinding()]
Param(
    [Parameter(Mandatory = $false)]
    [String]$SubscriptionAbbreviation = "dta",
    [Parameter(Mandatory = $false)]
    [String]$EnvironmentName = "dta"
)

$ApimResourceGroup = "das-$($EnvironmentName)-apim-rg"
$ApimServiceName = "das-$($EnvironmentName)-shared-apim"
$ResourceGroupList = @("das-$($SubscriptionAbbreviation)-mgmt-rg", $ApimResourceGroup, "das-$($EnvironmentName)-shared-rg")

Write-Host "Cleaning up APIM -> $ApimServiceName"
$ApimService = Get-AzApiManagement -ResourceGroupName $ApimResourceGroup -Name $ApimServiceName
if ($ApimService) {
    Write-Host "    -> $ApimServiceName"
    $ApimService | Remove-AzApiManagement
}

Write-Host "Cleaning up resource groups"
$ResourceGroupList | ForEach-Object {
    try {
        Write-Host "    -> $_"
        $null = Remove-AzResourceGroup -Name $_ -Force
    } catch {
        Write-Warning -Message "Failed to cleanup resource group $_"
    }
}
