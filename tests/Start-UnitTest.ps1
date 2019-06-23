Param(
    [System.IO.FileInfo]$Path = $PSScriptRoot
)

Clear-Host

$Header = @"
#######################################################################
#   Test Execution Mangaer                                            #
#   Run tests in the context of a new process to avoid poluting the   #
#   current runspace                                                  #
#   [For local execution only]                                        #
#######################################################################
"@

Write-Host $Header -ForegroundColor Green

$ArgumentList = @(
    "-NoExit"
    "-NoLogo"
    "-NoProfile"
    "-Command & {Invoke-Pester $Path -ExcludeTag e2e; exit}"
)

Start-Process PowerShell -NoNewWindow -ArgumentList $ArgumentList
