targetScope = 'subscription'

@description('Resource group name for deployment')
param resourceGroupName string

@description('List of Environment names')
param environmentNames array

param routes object

module environment 'environment.bicep' = [for environment in environmentNames:{
    scope: resourceGroup(resourceGroupName)
    name: 'shared-${toLower(environment)}-deployment'
    params: {
      routes: routes.value[environment]
      environment: toLower(environment)
    }
}]
