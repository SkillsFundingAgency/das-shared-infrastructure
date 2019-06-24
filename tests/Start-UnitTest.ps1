Param(
    [System.IO.FileInfo]$Path = $PSScriptRoot,
    [Switch]$LocalExecution
)

if ($LocalExecution.IsPresent) {

    Clear-Host

    $Header = @"
    #######################################################################
    #   Test Execution Manager                                            #
    #   Run tests in the context of a new process to avoid polluting the  #
    #   current runspace                                                  #
    #   [For local execution only]                                        #
    #######################################################################
"@

    Write-Host $Header -ForegroundColor Green

    $ArgumentList = @(
        "-NoExit"
        "-NoLogo"
        "-NoProfile"
        "-Command & {Invoke-Pester $Path; exit}"
    )

    Start-Process PowerShell -NoNewWindow -ArgumentList $ArgumentList

}
else {
    $Parameters = @{
        PassThru = $true
        OutputFormat = 'NUnitXml'
        OutputFile = "$PSScriptRoot\Test-Pester.XML"
    }

    Push-Location
    Set-Location -Path $PSScriptRoot
    $TestResults = Invoke-Pester @Parameters
    Pop-Location

    if ($TestResults.FailedCount -gt 0) {
        Write-Error "Failed '$($TestResults.FailedCount)' tests, build failed"
    }
}




