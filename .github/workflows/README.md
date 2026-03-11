# CI/CD Setup

## Prerequisites

Register a Microsoft Entra ID app registration (or service principal) and configure **federated credentials** for your GitHub repository so the workflow can authenticate without storing passwords.

### 1. Create a service principal and assign roles

```bash
# Create the service principal
az ad sp create-for-rbac --name "github-deployer" --role Contributor \
  --scopes /subscriptions/<SUBSCRIPTION_ID>/resourceGroups/<RESOURCE_GROUP> \
  --json-auth

# Grant AcrPush on the container registry
az role assignment create --assignee <CLIENT_ID> --role AcrPush \
  --scope /subscriptions/<SUBSCRIPTION_ID>/resourceGroups/<RESOURCE_GROUP>/providers/Microsoft.ContainerRegistry/registries/<ACR_NAME>
```

### 2. Add OIDC federated credential

```bash
az ad app federated-credential create --id <APP_OBJECT_ID> --parameters '{
  "name": "github-main",
  "issuer": "https://token.actions.githubusercontent.com",
  "subject": "repo:<OWNER>/<REPO>:ref:refs/heads/main",
  "audiences": ["api://AzureADTokenExchange"]
}'
```

### 3. Configure GitHub secrets

Go to **Settings → Secrets and variables → Actions → Secrets** and add:

| Secret                    | Value                              |
|---------------------------|------------------------------------|
| `AZURE_CLIENT_ID`        | Application (client) ID           |
| `AZURE_TENANT_ID`        | Directory (tenant) ID             |
| `AZURE_SUBSCRIPTION_ID`  | Azure subscription ID             |

### 4. Configure GitHub variables

Go to **Settings → Secrets and variables → Actions → Variables** and add:

| Variable            | Value                                          |
|---------------------|------------------------------------------------|
| `ACR_NAME`          | Your ACR name (e.g. `acrcipoccbyel34a`)       |
| `APP_SERVICE_NAME`  | Your App Service name (e.g. `app-m4bxmfqwkmjye`) |

### 5. Run the workflow

The workflow triggers on pushes to `main` that modify files under `src/`, or can be run manually via **Actions → Build and Deploy → Run workflow**.
