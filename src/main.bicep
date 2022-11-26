// Define target scope
targetScope = 'subscription'

// project name
@minLength(3)
@maxLength(10)
@description('Name of this project')
param projectName string

// author name
@description('Who created the project')
param author string

param utcShortValue string = utcNow('d')
var resourceTags = {
	createdBy: author
	createdAt: utcShortValue
}

//variables
var keyVaultName = '${projectName}-DK-KeyVault'
var sqlResource = '${projectName}-DK-SQLInstance'
var sqlServerName = '${projectName}-DK-SQLServer'
var sqlDatabseName = '${projectName}-DK-SQLServer-db1'
var appServicePlanName = '${projectName}-DK-App-LinuxPlan1'
var appInsightName = '${projectName}-DK-AppInsight1'
var appGWName = '${projectName}-DK-AppGw1'
var apiTestName = '${projectName}-DK-ApiTest1'

module resourceGrp './modules/resourcegroup.bicep' = {
  name: 'Microsoft.Resources'
  scope: subscription(config.subscription)
  params: {
    config: config
  }
}

module keyVault './modules/keyvault.bicep' = {
	name: keyVaultName
	scope: resourceGroup(config.resourceGroup)
	params: {
		kvName: keyVaultName
		tags: resourceTags
	}
	dependsOn: [
    resourceGrp
  ]
}

module database './modules/sqldatabase.bicep' = {
	name: sqlResource
	scope: resourceGroup(config.resourceGroup)
	params: {
		sqlServerName: sqlServerName
		sqlDatabseName: sqlDatabseName
		tags: resourceTags
		keyVaultName: keyVault.outputs.keyVaultName
		sqlConnectionStringSecretName: 'SQLConnectionString'
	}
	dependsOn: [
    resourceGrp
  ]
}

module appServicePlan './modules/appserviceplan.bicep' = {
	name: appServicePlanName
	scope: resourceGroup(config.resourceGroup)
	params: {
		appServicePlanName: appServicePlanName
		sku: 'P1V2'
	}
	dependsOn: [
    resourceGrp
  ]
}

module appinsight './modules/appinsight.bicep' = {
	name: appInsightName
	scope: resourceGroup(config.resourceGroup)
	params: {
		tags: resourceTags
		appInsightName: appInsightName
	}
	dependsOn: [
    resourceGrp
  ]
}

module apigateway './modules/webapp.bicep' = {
	name: appGWName
	scope: resourceGroup(config.resourceGroup)
	params: {
		webAppName: appGWName
		tags: resourceTags
		appServicePlanId: appServicePlan.outputs.appServicePlanId
		keyVaultName: keyVault.outputs.keyVaultName
		SQLConnectionStringSercretName: 'SQLConnectionString'
		appinsightInstrumentKey: appinsight.outputs.appinsightInstrumentKey
		AuthSecretKeyUri: keyVault.outputs.secretauthSercretKey
	}
	dependsOn: [
		appServicePlan
	]
}

module webservice1 './modules/webapp.bicep' = {
	name: apiTestName
	scope: resourceGroup(config.resourceGroup)
	params: {
		webAppName: apiTestName
		tags: resourceTags
		appServicePlanId: appServicePlan.outputs.appServicePlanId
		keyVaultName: keyVault.outputs.keyVaultName
		appinsightInstrumentKey: appinsight.outputs.appinsightInstrumentKey
		SQLConnectionStringSercretName: 'SQLConnectionString'
		AuthSecretKeyUri: keyVault.outputs.secretauthSercretKey
	}
	dependsOn: [
		appServicePlan
	]
}


param config object = loadJsonContent('configs/main.json')

output webappName string = apigateway.outputs.webappName
output webappUrl string = apigateway.outputs.webappUrl
