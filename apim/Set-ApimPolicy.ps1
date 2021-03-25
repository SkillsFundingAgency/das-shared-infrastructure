[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("DTA", "AT", "TEST", "TEST2", "DEMO", "PP", "PRD", "MO")]
    [String[]]$EnvironmentNames,
    [Parameter(Mandatory = $true)]
    [String]$CustomDomainHostedZone
)

$PolicyFilePath = "$PSScriptRoot/apim-policy.xml"
$EnvironmentNames | ForEach-Object {
    $PortalDomain = "portal." + $CustomDomainHostedZone
    if ($_ -ne "PRD") {
        $PortalDomain = "https://" + $_.ToLower() + "-" + $PortalDomain
    }
    else {
        $PortalDomain = "https://" + $PortalDomain
    }

    [xml]$XmlData = (Get-Content $PolicyFilePath)
    $XmlData.policies.inbound.cors.'allowed-origins'.origin = $PortalDomain
    $XmlData.Save($PolicyFilePath)
    $ApimContext = New-AzApiManagementContext -ResourceGroupName "das-$($_)-apim-rg".ToLower() -ServiceName "das-$($_)-shared-apim".ToLower()
    Set-AzApiManagementPolicy -Context $ApimContext -PolicyFilePath $PolicyFilePath
    Write-Output "APIM policy:"
    Get-AzApiManagementPolicy -Context $ApimContext
}
