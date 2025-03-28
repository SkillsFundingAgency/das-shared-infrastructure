using '../subscription.bicep'

param environmentNames = ['AT', 'TEST', 'TEST2', 'DEMO']
param resourceGroupName = 'das-dev-mgmt-rg'
param routes = {
  value: {
    at: [
      {
        name: 'All-AT-Outbound-To-Hub'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: '10.0.1.4'
        }
      }
      {
        name: 'APIManagement-To-Internet'
        properties: {
          addressPrefix: 'ApiManagement.WestEurope'
          nextHopType: 'Internet'
        }
      }
      {
        name: 'All-Internal-Traffic-To-Vnet'
        properties: {
          addressPrefix: '10.1.0.0/16'
          nextHopType: 'VnetLocal'
        }
      }
    ]
    test: [
      {
        name: 'All-TEST-Outbound-To-Hub'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: '10.0.1.4'
        }
      }
      {
        name: 'APIManagement-To-Internet'
        properties: {
          addressPrefix: 'ApiManagement.WestEurope'
          nextHopType: 'Internet'
        }
      }
      {
        name: 'All-Internal-Traffic-To-Vnet'
        properties: {
          addressPrefix: '10.1.0.0/16'
          nextHopType: 'VnetLocal'
        }
      }
    ]
    test2: []
    demo: []
  }
}
