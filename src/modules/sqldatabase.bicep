@description('name of the SQL Server')
param sqlServerName string

@description('name of the SQL Server')
param sqlDatabseName string


@description('name of the SQL Server')
param sqlConnectionStringSecretName string

@description('Resource tags for organizing / cost monitoring')
param tags object

@allowed([
	'Basic'
	'S0'
	'S1'
	'S2'
	'P1'
	'P2'
	'P3'
])
param performanceTier string = 'S0'

@description('Name of the KeyVault instance where we want to store secrets')
param keyVaultName string


var sqlAdminUsername = 'admin'
var sqlAdminPassword = 'Pass@word1'

resource sqlServer 'Microsoft.Sql/servers@2021-02-01-preview' = {
	name: sqlServerName
	location: resourceGroup().location
	tags: tags
	identity: {
		type: 'SystemAssigned'
	}
	properties: {
		administratorLogin: sqlAdminUsername
		administratorLoginPassword: sqlAdminPassword
	}

	resource sqlServerDatabase 'databases@2021-02-01-preview' = {
		name: sqlDatabseName
		location: resourceGroup().location
		tags: tags
		sku: {
			name: performanceTier
		}
		properties: {
			collation: 'SQL_Latin1_General_CP1_CI_AS'
		}
	}
}


// Add the SQL connection string to KeyVault
resource keyvault 'Microsoft.KeyVault/vaults@2019-09-01' existing = {
	name: keyVaultName

	resource sqlConnectionStringSecret 'secrets' = {
		name: sqlConnectionStringSecretName
		tags: tags
		dependsOn: [
			keyvault
		]
		properties: {
			value: 'Data Source=tcp:${sqlServer.properties.fullyQualifiedDomainName},1433;Initial Catalog=${sqlDatabseName};User Id=${sqlAdminUsername};Password=${sqlAdminPassword};'
			contentType: 'string'
			attributes: {
				enabled: true
			}
		}
	}
}
