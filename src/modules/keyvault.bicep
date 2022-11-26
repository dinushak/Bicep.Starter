@description('Name of the key vault')
param kvName string

@description('Resource tags for organizing / cost monitoring')
param tags object



resource keyVault 'Microsoft.KeyVault/vaults@2019-09-01' = {
	name: kvName
	location: resourceGroup().location
	tags: tags
	properties: {
		enabledForTemplateDeployment: true
		createMode: 'default'
		tenantId: subscription().tenantId
		accessPolicies: []
		sku: {
			name: 'standard'
			family: 'A'
		}
	}
}

var authSercretKey = guid(resourceGroup().id)
resource secretauthSercretKey 'Microsoft.KeyVault/vaults/secrets@2021-04-01-preview' = {
	name: 'authSercretKey'
	parent: keyVault
	tags: tags
	properties: {
		value: authSercretKey
		contentType: 'string'
		attributes: {
			enabled: true
		}
	}
}


output keyVaultName string = kvName
output keyVaultUri string = keyVault.properties.vaultUri
output secretauthSercretKey string = secretauthSercretKey.properties.secretUri
