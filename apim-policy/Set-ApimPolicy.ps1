$ENV:EnvironmentNames | ForEach-Object {
    Write-Host "Environment: $($_)"
    $ApimContext = New-AzApiManagementContext -ResourceGroupName "das-$($_)-apim-rg".ToLower() -ServiceName "das-$($_)-shared-apim".ToLower()
    Get-AzApiManagementPolicy -Context $ApimContext
    #Set-AzApiManagementPolicy -Context $ApimContext -PolicyFilePath "./apim-policy/apim-policy.xml"
}
