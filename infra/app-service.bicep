param location string
param appName string
param environment string
param appServicePlanName string
param appServiceName string
param containerImage string
param acrName string
param appInsightsInstrumentationKey string
param appInsightsConnectionString string
param foundryWorkspaceId string
param logAnalyticsWorkspaceId string
param tags object = {}

// Create App Service Plan
resource appServicePlan 'Microsoft.Web/serverfarms@2023-12-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: 'B2'
    tier: 'Basic'
    capacity: 1
  }
  kind: 'linux'
  properties: {
    reserved: true
  }
  tags: tags
}

// Create App Service
resource appService 'Microsoft.Web/sites@2023-12-01' = {
  name: appServiceName
  location: location
  kind: 'app,linux,container'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
    publicNetworkAccess: 'Enabled'
    siteConfig: {
      linuxFxVersion: 'DOCKER|${acrName}.azurecr.io/${containerImage}'
      acrUseManagedIdentityCreds: true
      alwaysOn: true
      minTlsVersion: '1.2'
      ftpsState: 'Disabled'
      http20Enabled: true
      detailedErrorLoggingEnabled: true
      appSettings: [
        {
          name: 'WEBSITES_ENABLE_APP_SERVICE_STORAGE'
          value: 'false'
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_URL'
          value: 'https://${acrName}.azurecr.io'
        }
        {
          name: 'DOCKER_ENABLE_CI'
          value: 'true'
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: appInsightsConnectionString
        }
        {
          name: 'ApplicationInsightsAgent_EXTENSION_VERSION'
          value: '~3'
        }
        {
          name: 'XDT_MicrosoftApplicationInsights_Mode'
          value: 'recommended'
        }
        {
          name: 'AZURE_FOUNDRY_WORKSPACE_ID'
          value: foundryWorkspaceId
        }
        {
          name: 'AZURE_LOG_ANALYTICS_WORKSPACE_ID'
          value: logAnalyticsWorkspaceId
        }
      ]
      connectionStrings: []
    }
  }
  tags: union(tags, {
    'azd-service-name': 'web'
  })
}

// WebSiteAuthentication for Managed Identity
resource authSettings 'Microsoft.Web/sites/config@2023-12-01' = {
  name: '${appService.name}/web'
  properties: {
    numberOfWorkers: 1
    defaultDocuments: [
      'Default.htm'
      'Default.html'
      'Default.asp'
      'index.htm'
      'index.html'
      'iisstart.htm'
      'default.aspx'
      'index.php'
      'hostingstart.html'
    ]
    netFrameworkVersion: 'v6.0'
    requestTracingEnabled: false
    remoteDebuggingEnabled: false
    httpLoggingEnabled: true
    detailedErrorLoggingEnabled: true
    publishingUsername: null
  }
}

output appServiceId string = appService.id
output appServiceUrl string = 'https://${appService.properties.defaultHostName}'
output appServiceName string = appService.name
output managedIdentityPrincipalId string = appService.identity.principalId
