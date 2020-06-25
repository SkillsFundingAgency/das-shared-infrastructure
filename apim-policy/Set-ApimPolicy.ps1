[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("DTA", "AT", "TEST", "TEST2", "DEMO", "PP", "PRD", "MO")]
    [String[]]$EnvironmentNames
)
$EnvironmentNames | ForEach-Object {
    Write-Output "Environment: $($_)"
    $ApimContext = New-AzApiManagementContext -ResourceGroupName "das-$($_)-apim-rg".ToLower() -ServiceName "das-$($_)-shared-apim".ToLower()
    Set-AzApiManagementPolicy -Context $ApimContext -PolicyFilePath "$PSScriptRoot/apim-policy.xml"
    Write-Output "APIM policy:"
    Get-AzApiManagementPolicy -Context $ApimContext
}
