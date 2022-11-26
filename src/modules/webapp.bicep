@description('Name of the web app')
param webAppName string

@description('Name of the key vault')
param keyVaultName string

@description('Resource tags for organizing / cost monitoring')
param tags object


@description('Name of the sql connection string secret name')
param SQLConnectionStringSercretName string

@description('Auth Secret Key Name')
param AuthSecretKeyUri string

@description('App service plan ID')
param appServicePlanId string

@description('App insight instrument key plan ID')
param appinsightInstrumentKey string



resource webapp 'Microsoft.Web/sites@2021-01-15' = {
	name: webAppName
	location: resourceGroup().location
	tags: tags
	identity: {
		type: 'SystemAssigned'
	}
	kind: 'app,linux'
	properties: {
		serverFarmId: appServicePlanId
		httpsOnly: true
		reserved: true
		siteConfig: {
			alwaysOn: true
			minTlsVersion: '1.2'
			linuxFxVersion: 'DOTNETCORE|6.0'
			appSettings: [
				{
					name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
					value: appinsightInstrumentKey
				}
				{
					name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
					value: 'InstrumentationKey=${appinsightInstrumentKey}'
				}
				{
					name: 'AuthSercretKey'
					value: '@Microsoft.KeyVault(SecretUri=${AuthSecretKeyUri})'
				}
			]
			connectionStrings: [
				{
					name: 'SQLDBConnectionString'
					connectionString: '@Microsoft.KeyVault(VaultName=${keyVaultName};SecretName=${SQLConnectionStringSercretName})'
					type: 'SQLAzure'
				}
			]
		}
	}
}

// Add the SQL connection string to KeyVault
resource keyvault 'Microsoft.KeyVault/vaults@2019-09-01' existing = {
	name: keyVaultName

	resource keyVaultAccessPolicy 'accessPolicies' = {
		name: 'add'
		properties: {
			accessPolicies: [
				{
					tenantId: webapp.identity.tenantId
					objectId: webapp.identity.principalId
					permissions: {
						keys: [
							'get'
						]
						secrets: [
							'list'
							'get'
						]
					}
				}
			]
		}
	}
}

output webappName string = webAppName
output webappUrl string = 'https://${webapp.properties.defaultHostName}'
