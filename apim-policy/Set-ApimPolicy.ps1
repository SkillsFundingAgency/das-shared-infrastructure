[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("DTA", "AT", "TEST", "TEST2", "DEMO", "PP", "PRD", "MO")]
    [String[]]$EnvironmentNames
)
$EnvironmentNames | ForEach-Object {
    Write-Host "Environment: $($_)"
    $ApimContext = New-AzApiManagementContext -ResourceGroupName "das-$($_)-apim-rg".ToLower() -ServiceName "das-$($_)-shared-apim".ToLower()
    Set-AzApiManagementPolicy -Context $ApimContext -PolicyFilePath "$PSScriptRoot/apim-policy/apim-policy.xml"
    Get-AzApiManagementPolicy -Context $ApimContext
}
