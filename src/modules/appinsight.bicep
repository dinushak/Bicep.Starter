@description('Name of the web app')
param appInsightName string

@description('Resource tags for organizing / cost monitoring')
param tags object

resource appInsights 'Microsoft.Insights/components@2020-02-02-preview' = {
	name: appInsightName
	location: resourceGroup().location
	kind: 'web'
	tags: tags
	properties: {
		Application_Type: 'web'
		Flow_Type: 'Bluefield'
		Request_Source: 'rest'
	}
}

output appinsightInstrumentKey string = appInsights.properties.InstrumentationKey
