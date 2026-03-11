targetScope = 'resourceGroup'

param location string = 'westus3'
param environment string = 'dev'
param appName string = 'zavastorefront'
param containerImage string = 'zavastorefront:latest'
param acbAccountName string = 'acr${take(uniqueString(resourceGroup().id, appName, environment), 20)}'
param appServicePlanName string = 'plan-${appName}-${environment}'
param appServiceName string = 'app-${take(uniqueString(subscription().id, resourceGroup().name, appName, environment), 20)}'
param appInsightsName string = 'ai-${appName}-${environment}'
param logAnalyticsName string = 'log-${appName}-${environment}'
param foundryName string = 'aif-${appName}-${environment}'
param tags object = {}

// Deploy Log Analytics Workspace first (prerequisite for diagnostics)
module logAnalytics 'monitoring.bicep' = {
  name: 'logAnalyticsModule'
  params: {
    location: location
    logAnalyticsName: logAnalyticsName
    appInsightsName: appInsightsName
    tags: tags
  }
}

// Deploy Container Registry
module containerRegistry 'container-registry.bicep' = {
  name: 'containerRegistryModule'
  params: {
    location: location
    acrName: acbAccountName
    tags: tags
  }
}

// Deploy Microsoft Foundry Workspace
module foundry 'foundry.bicep' = {
  name: 'foundryModule'
  params: {
    location: location
    foundryName: foundryName
    logAnalyticsWorkspaceId: logAnalytics.outputs.logAnalyticsWorkspaceId
    tags: tags
  }
}

// Deploy App Service with Managed Identity
module appService 'app-service.bicep' = {
  name: 'appServiceModule'
  params: {
    location: location
    appName: appName
    environment: environment
    appServicePlanName: appServicePlanName
    appServiceName: appServiceName
    containerImage: containerImage
    acrName: acbAccountName
    appInsightsInstrumentationKey: logAnalytics.outputs.appInsightsInstrumentationKey
    appInsightsConnectionString: logAnalytics.outputs.appInsightsConnectionString
    foundryWorkspaceId: foundry.outputs.foundryWorkspaceId
    logAnalyticsWorkspaceId: logAnalytics.outputs.logAnalyticsWorkspaceId
    tags: tags
  }
  dependsOn: [
    containerRegistry
    foundry
    logAnalytics
  ]
}

// Assign RBAC roles for managed identity
module rbacAssignments 'rbac.bicep' = {
  name: 'rbacModule'
  params: {
    appServiceManagedIdentityPrincipalId: appService.outputs.managedIdentityPrincipalId
    acrId: containerRegistry.outputs.acrId
    foundryId: foundry.outputs.foundryId
  }
}

// Enable Diagnostic Settings
module diagnostics 'diagnostics.bicep' = {
  name: 'diagnosticsModule'
  params: {
    appServiceId: appService.outputs.appServiceId
    foundryId: foundry.outputs.foundryId
    logAnalyticsWorkspaceId: logAnalytics.outputs.logAnalyticsWorkspaceId
    appInsightsResourceId: logAnalytics.outputs.appInsightsResourceId
  }
}

output appServiceUrl string = appService.outputs.appServiceUrl
output acrLoginServer string = containerRegistry.outputs.acrLoginServer
output appInsightsInstrumentationKey string = logAnalytics.outputs.appInsightsInstrumentationKey
