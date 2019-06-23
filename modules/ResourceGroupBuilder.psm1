class ResourceGroupBuilder {

    ResourceGroupBuilder() {
    }

    [String[]] CreateResourceGroups([String]$SubscriptionAbbreviation, [String[]]$EnvironmentNames, [String]$Location, [Hashtable]$Tags) {

        # --- Create Resource Groups
        $ManagementResourceGroupName = "das-$($SubscriptionAbbreviation)-mgmt-rg".ToLower()
        $ResourceGroupList = [System.Collections.ArrayList]::new(@($ManagementResourceGroupName))
        $ResourceGroupList.AddRange(@($EnvironmentNames | ForEach-Object { "das-$($_)-shared-rg".ToLower() }))

        Write-Host "- Creating Resource Groups ->"
        $ResourceGroupList | ForEach-Object {
            Write-Host "    - $_"
            $ResourceGroup = Get-AzResourceGroup -Name $_ -Location $Location -ErrorAction SilentlyContinue
            if (!$ResourceGroup) {
                $null = New-AzResourceGroup -Name $_ -Location $Location -Tag $Tags -Confirm:$false
            }
            else {
                Write-Verbose -Message "Resource group $($ResourceGroup.ResourceGroupName) exists, validating tags"
                $UpdateTags = $false
                if ($ResourceGroup.Tags) {
                    # Check existing tags and update if necessary
                    $UpdatedTags = $ResourceGroup.Tags
                    foreach ($Key in $Tags.Keys) {
                        Write-Verbose "Current value of Resource Group Tag $Key is $($ResourceGroup.Tags[$Key])"
                        if ($($ResourceGroup.Tags[$Key]) -eq $($Tags[$Key])) {
                            Write-Verbose -Message "Current value of tag ($($ResourceGroup.Tags[$Key])) matches parameter ($($Tags[$Key]))"
                        }
                        elseif ($null -eq $($ResourceGroup.Tags[$Key])) {
                            Write-Verbose -Message ("Tag value is not set, adding tag {0} with value {1}" -f $Key, $Tags[$Key])
                            $UpdatedTags[$Key] = $Tags[$Key]
                            $UpdateTags = $true
                        }
                        else {
                            Write-Verbose -Message ("Tag value is incorrect, setting tag {0} with value {1}" -f $Key, $Tags[$Key])
                            $UpdatedTags[$Key] = $Tags[$Key]
                            $UpdateTags = $true
                        }
                    }
                }
                else {
                    # No tags to check, just update with the passed in tags
                    $UpdatedTags = $Tags
                    $UpdateTags = $true
                }
                if ($UpdateTags) {
                    Write-Host "    - Updating existing tags [$($UpdatedTags.Keys -join ',')]"
                    $null = Set-AzResourceGroup -Name $ResourceGroup.ResourceGroupName -Tag $UpdatedTags
                }
            }
        }
        return $ResourceGroupList
    }
}
