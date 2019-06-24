using module '.\modules\InitializationHelper.psm1'
using module '.\modules\ResourceGroupBuilder.psm1'
using module '.\modules\FailoverGroupBuilder.psm1'
using module '.\modules\ParametersFileBuilder.psm1'

<#
.SYNOPSIS
Shared infrastructure deployment helper

.DESCRIPTION
Pre deployment script for shared infrastructure deployments. It is designed to be ran in the context of a
build agent or from a local machine.

Build agent deployments:
    * This script only prepares the deployment environment
    * Ensure that the correct template environment variables are present in the release definition
    * Use the ARM template deployment task
    * Secret variables must be passed as override parameters to the ARM tepmlate deployment release task
Local deployments:
    * ONLY to be used for testing and NOT against any environments that are in service
    * The script looks for matching environment variables. If they are not present you will be prompted to enter the values
    * When not in the context of a build server, this script will create the deployment.

.PARAMETER SubscriptionAbbreviation
Abbreviation of the subscription. It is possible for a subscription to have many environments, for example,
a development subscription can contain many development environments.

Default: DEV

.PARAMETER EnvironmentNames
A JSON array of environments to create in a subscription. For example:
"["AT","TEST""]

Default: $ENV:EnvironmentNames

.PARAMETER Location
The location of the resources.

Default: West Europe

#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [ValidateSet("DTA", "DEV", "PP", "PRD", "MO")]
    [string]$SubscriptionAbbreviation = "DEV",
    [Parameter(Mandatory = $false)]
    [ValidateSet("DTA", "AT", "TEST", "TEST2", "DEMO", "PP", "PRD", "MO")]
    [string[]]$EnvironmentNames,
    [Parameter(Mandatory = $false)]
    [ValidateSet("West Europe", "North Europe")]
    [string]$Location = "West Europe",
    [Parameter(Mandatory = $false)]
    [switch]$AcceptDefaults
)

$TemplateFilePath = "$PSScriptRoot/templates/subscription.template.json"
$TemplateParametersFilePath = "$PSScriptRoot/templates/subscription.parameters.json"

try {
    # --- Are We Logged in?
    [InitializationHelper]::IsLoggedIn()

    $ParsedEnvironmentNames = [InitializationHelper]::ParseEnvironmentNames($PSBoundParameters)

    # --- Create resource groups
    $Tags = @{
        Environment        = $ENV:EnvironmentTag
        'Parent Business'  = $ENV:ParentBusinessTag
        'Service Offering' = $ENV:ServiceOfferingTag
    }
    $ResourceGroupBuilder = [ResourceGroupBuilder]::New()
    $null = $ResourceGroupBuilder.CreateResourceGroups($SubscriptionAbbreviation, $ParsedEnvironmentNames, $Location, $Tags)

    # --- Create failover group configuration
    $FailoverGroupBuilder = [FailoverGroupBuilder]::New()
    $ENV:DatabaseConfiguration = $FailoverGroupBuilder.CreateFailoverGroupConfig($ParsedEnvironmentNames)

    # --- Create parameters file
    $ParametersFileBuilder = [ParametersFileBuilder]::New()
    $ParametersFileConfig = $ParametersFileBuilder.CreateParametersFileConfig($TemplateFilePath)
    $ParametersFileBuilder.Save($ParametersFileConfig, $TemplateParametersFilePath)

    # --- Deploy if local and !testing
    [InitializationHelper]::DeployTemplate($ManagementResourceGroupName, $TemplateFilePath, $TemplateParametersFilePath)

}
catch {
    $PSCmdlet.ThrowTerminatingError($_)
}
