param location string
param foundryName string
param logAnalyticsWorkspaceId string
param tags object = {}

// Create Azure AI Foundry Hub
resource aiFoundryHub 'Microsoft.MachineLearningServices/workspaces@2024-01-01-preview' = {
  name: foundryName
  location: location
  kind: 'hub'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    displayName: 'Zava Storefront AI Hub'
    description: 'Microsoft Foundry workspace for Zava Storefront application'
    friendlyName: foundryName
    publicNetworkAccess: 'Enabled'
    containerRegistry: null
    storageAccount: null
    keyVault: null
    applicationInsights: null
  }
  tags: tags
}

// Create AI Foundry Project
resource aiFoundryProject 'Microsoft.MachineLearningServices/workspaces@2024-01-01-preview' = {
  name: '${foundryName}-project'
  location: location
  kind: 'project'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    displayName: 'Zava Storefront Project'
    description: 'Project workspace for Zava Storefront'
    hubResourceId: aiFoundryHub.id
    publicNetworkAccess: 'Enabled'
  }
  tags: tags
  dependsOn: [
    aiFoundryHub
  ]
}

output foundryId string = aiFoundryProject.id
output foundryWorkspaceId string = aiFoundryProject.name
output foundryName string = aiFoundryProject.name
output foundryHubId string = aiFoundryHub.id
