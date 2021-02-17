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

Write-Host "Getting APIM service"
$ApimService = Get-AzApiManagement -ResourceGroupName $ApimResourceGroup -Name $ApimServiceName -ErrorAction SilentlyContinue
if ($ApimService) {
    Write-Host "    -> $ApimServiceName"
    $ApimService | Remove-AzApiManagement
}
else {
    Write-Host "    -> $ApimServiceName not found"
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
