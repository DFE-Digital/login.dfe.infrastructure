## Infrastructure Overview

This repository contains the **pre-requisite** and **base infrastructure** for deploying DfE Sign-in services.

---

## Prerequisites

> **Note:** The `keyvault` mentioned below refers to the deployed Key Vault in the specific environment where the pre-requisite infrastructure has run. The naming format is:  
> `s141<EnvId>-signin-kv`

1. **Azure Active Directory (AAD) App Registrations**  
   - Three app registrations are required (already set, but may be needed when switching tenants):
     - **Service connection** for pipeline deployment across environments. May require CIP team approval.  
       Name: `S141<SubscriptionInitial>.bsvc.cip.azdo`
     - **AAD Admin** for SQL Server connection. May require CIP team approval.  
       Name: `s141-dfesignin-<EnvironmentName>-sql-admin`

2. **Additional AAD App Registrations** (required for new environments):
   - App authentication: `S141<EnvId>-app`  
     [How to create](https://github.com/DFE-Digital/login.dfe.devops/blob/main/Docs/AppRegistrations.md)
   - Client authentication: `S141<EnvId>-client`  
     [How to create](https://github.com/DFE-Digital/login.dfe.devops/blob/main/Docs/AppRegistrations.md)
   - Add `S141<EnvId>-app` objectId to Key Vault (`aadshdappid`)
   - Add `S141<EnvId>-client` objectId and secret to Key Vault (`aadshdclientid`, `aadshdclientsecret`)

3. **GitHub Personal Access Token**  
   Required to access private repositories for deployment.  
   [How to create](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token)

4. **Pipeline Configuration Notes**
   - Comment out the scan tool stage in `azure-pipeline.yml` when deploying to an empty subscription for the first time.
   - Check for inner dependencies in the code that may affect `azure-pipeline.yml`.
   - Set `deployPrivateEndpoint` to `true` during deployment, then revert to `false`.
   - Set `destructiveVirtualNetworkDeploy` to `Enabled` during initial VNet deployment, then revert to `Disabled`.
   - For new resource groups (e.g., `s141<EnvId>-shd`) requiring VNet creation, CIP team approval is needed.

---

## Deployment

All external files (ARM templates, scripts, YAML) are located in the `login.dfe.devops` repository.

The infrastructure pipeline has two stages:

1. **Scan Infrastructure**  
   Uses Checkov to scan YAML and ARM templates.

2. **Deployment Stage**  
   Contains two jobs:
   - **Pre-deployment Job**  
     Creates Logic App `s141<EnvId>-signin-git` and Key Vault.  
     ARM template: `preDeployInfrastructure.json`
   - **Base Infrastructure Job**  
     Deploys all components using `template.json` in `DevOps/templates`.

For triggers and approvals, see:  
[Pipeline Trigger Documentation](https://github.com/DFE-Digital/login.dfe.devops/blob/main/Docs/PipelineTrigger.md)

> The pipeline includes a parameter to trigger pre-requisite infrastructure deployment if needed.

---

## Post Deployment

### Secrets

All secrets must be added to the deployed environment. Secrets added by the pipeline will automatically populate the Key Vault after pre-deployment completes.

Examples include:
- `appInsightsInstrumentationKey`
- `auditServiceBusSubscriptionName`
- `auditSqlDbName`
- `tenantUrl`
- `cdnAssetsVersion`
- `redisConn` (format: `redis://:<primary key>@<host>:<port>`)
- `platformGlobalNodeStart`
- `platformGlobalPm2Instances`
- `platformGlobalOrganisationsDatabaseName`
- `supportEmailAddress`
- `googleAnalyticsID`
- `giasServiceUsername`, `giasServicePassword`, `giasServiceUrl`, etc.
- `NotifyKey` (GovNotify SMS)
- `environmentBannerMessage`
- `sessionSecret`, `sessionEncryptionSecret`
- `cryptoPublicKey`, `cryptoPrivateKey`
- `coronaFormRedirectUrl`
- `helpClientSecret`, `assertionsSecret`, `aformsClientSecret`, `aformsClientId`
- `aspSettings`, `s2sSettings`, `collectSettings`
- Slack webhook: `uriSlack` for `dfe_sign_in_deployments`

### Certificates

For Front Door certificates:

1. Add Certificate Authority to Key Vault  
   [Documentation](https://learn.microsoft.com/en-us/azure/key-vault/certificates/how-to-integrate-certificate-authority)

2. If generating new certificates:
   - Use Key Vault > Certificates > Generate/Import
   - Set DNS names, validity (12 months), content type, lifetime actions, etc.

3. If importing existing certificates:
   - Use Key Vault > Certificates > Import
   - Upload file and provide password if needed

4. Update `azure-pipelines-gw.yml` with the certificate name under `sslCertificateName`.

More info:  
[Certificate Signing Request](https://learn.microsoft.com/en-us/azure/key-vault/certificates/create-certificate-signing-request?tabs=azure-portal)

---

## Variable Groups

[How to Set Variable Groups](https://github.com/DFE-Digital/login.dfe.devops/blob/main/Docs/VariableGroupSecrets.md)

---

## Next Pipelines

> All pipelines except Front Door are documented [here](https://github.com/DFE-Digital/login.dfe.devops/blob/main/Docs/PipelineTrigger.md)

**Important:**  
For Access, Directory, Applications, Organisation, Organisation-worker, Search, Search-worker, and Jobs:
- Run Infrastructure first.
- The task `Add Web IP Access restriction for backend & mid tier` may fail.
- `Create infrastructure` will succeed.
- Then run the full pipeline.

Pipeline list:

1. [Front Door Pipeline](https://github.com/DFE-Digital/login.dfe.devops/blob/main/Docs/FrontDoor;.md)
2. `ui.tool.kit` & `audit-logger`
3. Access, Directory & Applications
4. Organisation, Organisation-worker, Search & Search-worker
5. Jobs
6. OIDC & Interaction
7. Service
8. Help, Profile, Support, Public API & Manage
9. SAML Assertions
10. All SAML services (Aform, ASP, Collect, DQT, GIAS, S2S)
11. [DataFactory](https://github.com/DFE-Digital/login.dfe.datafactory.reporting/blob/main/README.md)