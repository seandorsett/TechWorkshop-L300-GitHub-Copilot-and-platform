param appServiceManagedIdentityPrincipalId string
param acrId string
param foundryId string

// Assign AcrPull role to App Service managed identity on ACR
resource acrPullRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: acrResource
  name: guid(acrResource.id, appServiceManagedIdentityPrincipalId, 'AcrPull')
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '7f951dda-4ed3-4680-a7ca-43fe172d538d')
    principalId: appServiceManagedIdentityPrincipalId
    principalType: 'ServicePrincipal'
  }
}

// Assign Cognitive Services User role to App Service managed identity on Foundry
resource cognitiveServicesUserRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: foundryResource
  name: guid(foundryResource.id, appServiceManagedIdentityPrincipalId, 'CognitiveServicesUser')
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'a97b65f3-24c7-4388-baec-2e87135dc908')
    principalId: appServiceManagedIdentityPrincipalId
    principalType: 'ServicePrincipal'
  }
}

// Reference existing resources
resource acrResource 'Microsoft.ContainerRegistry/registries@2023-01-01-preview' existing = {
  scope: resourceGroup()
  name: last(split(acrId, '/'))
}

resource foundryResource 'Microsoft.MachineLearningServices/workspaces@2024-01-01-preview' existing = {
  scope: resourceGroup()
  name: last(split(foundryId, '/'))
}
