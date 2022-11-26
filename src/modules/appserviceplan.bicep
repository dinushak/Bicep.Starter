@description('Name of the app service plan')
param appServicePlanName string

@allowed([
	'B1'
	'B2'
	'B3'
	'D1'
	'F1'
	'FREE'
	'I1'
	'I1v2'
	'I2'
	'I2v2'
	'I3'
	'I3v2'
	'P1V2'
	'P1V3'
	'P2V2'
	'P2V3'
	'P3V2'
	'P3V3'
	'PC2'
	'PC3'
	'PC4'
	'S1'
	'S2'
	'S3'
])
param sku string = 'B1'

resource servicePlan 'Microsoft.Web/serverfarms@2021-01-15' = {
	name: appServicePlanName
	location: resourceGroup().location
	kind: 'linux'
	sku: {
		name: sku
		capacity: 1
	}
	properties: {
		reserved: true
	}
}


output appServicePlanId string = servicePlan.id
