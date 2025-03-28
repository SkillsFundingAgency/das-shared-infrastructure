@description('Array of Objects with routing infomation')

param routes array

param environment string

var resourceNamePrefix = 'das-${environment}-shared'
var resourceGroupName = '${resourceNamePrefix}-rg'
var routeTableName = toLower('${resourceNamePrefix}-rt')

module routeTable 'br:dasdevbicepacr.azurecr.io/route-table:0.0.1' = {
  name: 'routeTable'
  scope: resourceGroup(resourceGroupName)
  params: {
    routeTableName: routeTableName
    disableBgpRoutePropagation: false
    routes: routes
  }
}
