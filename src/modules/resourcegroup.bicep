targetScope = 'subscription'
param config object

resource resourceGroup 'Microsoft.Resources/resourceGroups@2020-06-01' = {
  name: config.resourceGroup
  location: config.location
  properties: {}
  tags: config.tags
}
