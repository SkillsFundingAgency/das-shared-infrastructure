[CmdletBinding()]
Param(
    [Parameter(Mandatory = $false)]
    [ValidateSet("DTA", "AT", "TEST", "TEST2", "DEMO", "PP", "PRD", "MO")]
    [String[]]$EnvironmentNames
)

$EnvironmentNames | ForEach-Object {
    $ApimContext = New-AzApiManagementContext -ResourceGroupName "das-$($_)-apim-rg".ToLower() -ServiceName "das-$($_)-shared-apim".ToLower()
    Write-Host "Environment: $($_)"
    Get-AzApiManagementPolicy -Context $ApimContext
    #Set-AzApiManagementPolicy -Context $ApimContext -PolicyFilePath "./apim-policy/apim-policy.xml"
}
