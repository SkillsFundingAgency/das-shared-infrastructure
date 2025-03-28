@description('Array of Objects with routing infomation')

param routes array

param environment string

var resourceNamePrefix = 'das-${environment}-shared'
var resourceGroupName = '${resourceNamePrefix}-rg'
var routeTableName = toLower('${resourceNamePrefix}-rt')

module routeTable 'br/public:avm/res/network/route-table:0.4.0' = {
  name: 'routeTable'
  scope: resourceGroup(resourceGroupName)
  params: {
    name: routeTableName
    disableBgpRoutePropagation: false
    routes: routes
  }
}
