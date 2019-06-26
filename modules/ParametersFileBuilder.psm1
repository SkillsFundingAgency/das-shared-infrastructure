class ParametersFileBuilder {

    [PSCustomObject] CreateParametersFileConfig([String]$TemplateFilePath) {
        # --- Set Template parameters
        Write-Host "- Building deployment parameters file ->"
        $ParametersFile = [PSCustomObject]@{
            "`$schema"     = "http://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#"
            contentVersion = "1.0.0.0"
            parameters     = @{ }
        }

        [PSCustomObject]$TemplateParameters = (Get-Content -Path $TemplateFilePath -Raw | ConvertFrom-Json -ErrorAction Stop).parameters
        foreach ($Property in $TemplateParameters.PSObject.Properties.Name) {
            $ParameterEnvironmentVariableName = $TemplateParameters.$Property.metadata.environmentVariable
            $ParameterEnvironmentVariableType = $TemplateParameters.$Property.type

            Write-Host "    - [$ParameterEnvironmentVariableType]$ParameterEnvironmentVariableName"

            # --- First look for an environment variable
            Write-Verbose -Message "Attempting to resolve environment variable for $ParameterEnvironmentVariableName"
            $ParameterVariableValue = Get-Item -Path "ENV:$ParameterEnvironmentVariableName" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Value

            # --- If !$ParameterVariableValue attempt to use the default value property
            if (!$ParameterVariableValue) {
                Write-Verbose -Message "Environment variable for $Property was not found, attempting default value"
                $ParameterVariableValue = $TemplateParameters.$Property.defaultValue

                if ($ParameterVariableValue) {
                    Write-Verbose -Message "Using default value for $Property"

                    if ($ParameterEnvironmentVariableType -eq "object") {
                        $ParameterVariableValue = $ParameterVariableValue | ConvertTo-Json -Depth 10
                    }
                }
            }
            else {
                Write-Verbose -Message "Using environment variable value for $Property"
            }

            # --- If !$ParameterVariableValue and it is not a securestring throw
            if (!$ParameterVariableValue -and ($ParameterEnvironmentVariableType -ne "securestring")) {
                Write-Verbose -Message "Default value for $Property was not found. Process will terminate"
                throw "Could not find environment variable or default value for template parameter $Property"
            }

            switch ($ParameterEnvironmentVariableType) {
                'array' {
                    $ParameterVariableValue = [String[]]($ParameterVariableValue | ConvertFrom-Json)
                    break
                }
                'int' {
                    $ParameterVariableValue = [Int]$ParameterVariableValue
                    break
                }
                'object' {
                    $ParameterVariableValue = $ParameterVariableValue | ConvertFrom-Json
                    break
                }
                "default" {
                    Write-Warning -Message "Unknown type $ParameterEnvironmentVariableType"
                }
            }

            $ParametersFile.parameters.Add($Property, @{ value = $ParameterVariableValue })
        }
        return $ParametersFile

    }

    [void] Save([PSCustomObject]$ParametersFile, [String]$TemplateParametersFilePath) {
        try {
            Write-Host "- Saving parameters file"
            $null = Set-Content -Path $TemplateParametersFilePath -Value ([Regex]::Unescape(($ParametersFile | ConvertTo-Json -Depth 10))) -Force
            Write-Host "- Parameter file content saved to $TemplateParametersFilePath"
        } catch {
            Write-Error -Message "An error occured when attempting to save the parameters file: $_"
        }

    }
}
