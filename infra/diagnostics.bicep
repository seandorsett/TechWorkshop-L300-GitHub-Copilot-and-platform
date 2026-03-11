param appServiceId string
param foundryId string
param logAnalyticsWorkspaceId string
param appInsightsResourceId string

// Diagnostic Settings for App Service
resource appServiceDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: '${last(split(appServiceId, '/'))}-diagnostics'
  scope: appServiceResource
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logs: [
      {
        category: 'AppServiceHTTPLogs'
        enabled: true
        retentionPolicy: {
          enabled: false
          days: 0
        }
      }
      {
        category: 'AppServiceConsoleLogs'
        enabled: true
        retentionPolicy: {
          enabled: false
          days: 0
        }
      }
      {
        category: 'AppServiceAppLogs'
        enabled: true
        retentionPolicy: {
          enabled: false
          days: 0
        }
      }
      {
        category: 'AppServiceAuditLogs'
        enabled: true
        retentionPolicy: {
          enabled: false
          days: 0
        }
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
        retentionPolicy: {
          enabled: false
          days: 0
        }
      }
    ]
  }
}

// Reference existing resources
resource appServiceResource 'Microsoft.Web/sites@2023-12-01' existing = {
  name: last(split(appServiceId, '/'))
}

resource foundryResource 'Microsoft.MachineLearningServices/workspaces@2024-01-01-preview' existing = {
  name: last(split(foundryId, '/'))
}

resource appInsightsResource 'Microsoft.Insights/components@2020-02-02' existing = {
  name: last(split(appInsightsResourceId, '/'))
}
