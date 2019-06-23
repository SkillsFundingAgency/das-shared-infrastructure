class InitializationHelper {

    InitializationHelper() {
    }

    static [void] IsLoggedIn() {
        $IsLoggedIn = $null -ne (Get-AzContext -ErrorAction SilentlyContinue).Account
        if (!$IsLoggedIn) {
            Write-Error -Message "You are not logged in. Run Add-AzAccount to continue" -ErrorAction Stop
        }
    }

    static [String[]] ParseEnvironmentNames([Hashtable]$InputObject) {
        $EnvironmentNames = @()

        if ($InputObject.ContainsKey("EnvironmentNames")) {
            $EnvironmentNames = $InputObject['EnvironmentNames'] | ConvertTo-Json -ErrorAction Stop
            $ENV:EnvironmentNames = $EnvironmentNames
            Write-Verbose -Message "ENV:EnvironmentNames has been successfully set to $($ENV:EnvironmentNames) from parameter input"
        }
        elseif ($ENV:EnvironmentNames) {
            try {
                Write-Verbose -Message "Testing ENV:EnvironmentNames value"
                $EnvironmentNames = $ENV:EnvironmentNames | ConvertFrom-Json -ErrorAction Stop
            }
            catch {
                Write-Error -Message "ENV:EnvironmentNames value is not valid. $($_.Exception.Message)" -ErrorAction Stop
            }
        }
        else {
            Write-Error -Message "Could find EnvironmentNames value from parameter input or ENV" -ErrorAction Stop
        }

        return $EnvironmentNames
    }

    static [void] DeployTemplate([String]$ResourceGroupName, [String]$TemplateFilePath, [String]$TemplateParametersFilePath) {
        if (!$ENV:TF_BUILD -and !$ENV:isTest) {
            Write-Host "- Deploying $TemplateFilePath"
            $DeploymentParameters = @{
                ResourceGroupName       = $ResourceGroupName
                TemplateParameterFile   = $TemplateParametersFilePath
                TemplateFile            = $TemplateFilePath
                DeploymentDebugLogLevel = "All"
            }
            New-AzResourceGroupDeployment @DeploymentParameters
        }
    }
}
