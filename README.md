# Infrastructure

This repo contains pre & base infrastructure for the deployment of DfE signin services.

## Audience
---
This document refers to the DevOps engineers who will maintain this pipeline. Also, the responsibility to keep this document up to date with the latest information

## Prerequisite
---
*The `keyvault` that is mention below is representing the deploy keyvault in the specific environment that the Pre-requzet Infrastructure has run with name format `s141<EnvId>-signin-kv`

1. Azure Active Directory needs 3 App registrations created by the DevOps team. (This Prerequisite is already set. This may be needed when moving tenants )
   1. Service connections for the pipeline to be able to deploy in all environments. May need approval from the CIP team -> Name: `S141<Subscriptions enitial Letter>.bsvc.cip.azdo`
   2. Azure Active Directory Admin for the use of connection in the SQL server. May need approval from the CIP team -> Name: `s141-dfesignin-<Environment Name>-sql-admin`
2. Azure Active Directory needs 2 App registrations created by the devops team. (This Prerequisite is already set. But for new environments they will be needed)
   1. The will be the authentication for the app services with the name `S141EnvId-app` how to create [here](https://github.com/DFE-Digital/login.dfe.devops/blob/main/Docs/AppRegistrations.md)
   2. The will be the authentication for the client services with the name `S141EnvId-client` how to created [here](https://github.com/DFE-Digital/login.dfe.devops/blob/main/Docs/AppRegistrations.md)
   3. Add the `S141<EnvId>-app` objectId in the keyvault (`s141<EnvId>-signin-kv`) with the name `aadshdappid`  
   4. Add the `S141<EnvId>-client` objectId in the keyvault(`s141<EnvId>-signin-kv`) with the name `aadshdclientid` & secret with the name `aadshdclientsecret`
3. Personal access token from GitHub to access the private repo for the deployment. How to create [here](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token)
4. Comment out the scan tool stage of the pipeline for the first time you deploy an empty subscription -> File: azure-pipeline.yml
5. Check the code to see if any inner dependency exists as may be added later in azure-pipeline.yml file
6. Updated parameter `deployPrivateEndpoint` from false to true for deploying all the private endpoints and after deployment changes back to false in azure-pipeline.yml
7. Updated variable `destructiveVirtualNetworkDeploy` from Disabled to Enabled for deploying the vnet the First time and after deployment changes back to Disabled in azure-pipeline.yml
8. When new `s141<EnvId>-shd` resource group or any other resource group is deployed with a need of virtual Network creation, the CIP team needs to allow the virtual Network creation in that resource group

## Deployment
---
All external files are located in login.dfe.devops such us Global ARM templates, Sripts & YAML files
The infrastructure pipeline has two stages:

1. Scan Infrastructure that will use checkov to scan the yml & ARM templates for the deployment
2. Deployment stage that has two jobs under:
   1. Pre-deployments Job that will create the logic app `s141<EnvId>-signin-git` and the Keyvault that will use in the deployed environment in azure devops after the first run of any new subscription or environment. The ARM template is located in login.dfe.devops with name `preDeployInfrastrusture.json`
   2. Base infrastructure Job that will deploy all the specified componets using the template.json under the DevOps/templates folder

More information of trigger & Approvols please check [here](https://github.com/DFE-Digital/login.dfe.devops/blob/main/Docs/PipelineTrigger.md)

Also, this pipeline has an extra parameter in the pipeline to trigger the Pre-Requisites for deploying the pre-requisites infrastructure if needed 

## Post Deployment

### Secrets
--- 
*All secret must be added in the deployed environment
*All Add by pipeline secrets will automatically be added in the keyvault after the pre-deployment infrastructure completes 

1. Add by pipeline, app insights instrumentation key in the keyvault with the name `appInsightsInstrumentationKey`
2. Add by pipeline, audit Service Bus Subscription Name in the keyvault with the name  `auditServiceBusSubscriptionName`
3. Add by pipeline, audit Service Bus Topic Name in the keyvault with the name  `auditServiceBusTopicName`
4. Add by pipeline, audit SQL Database Name in the keyvault with name  `auditSqlDbName`
5. Add by pipeline, audit SQL Host Name in the keyvault with the name  `auditSqlHostName`
6. Add tenant Url in the keyvault with the name `tenantUrl`
7. Add by pipeline, CDN Assets Version in the keyvault with the name `cdnAssetsVersion`
8. Add by pipeline, CDN Host Name in the keyvault with the name `cdnHostName`
9. All Add by pipeline hosts/Urls names of the app services with the name schema `standalone<Appservice Full Name>HostName`. P.S For All frond-end services use the Certificate domain/if no certificate exists for the domain use the app service default schema 
10. Add by pipeline, redis Connection in the keyvault with the name `redisConn` & format `redis://:<primary key>@<Host name>:<port name>`
11. Add by pipeline, Node start file path in the keyvault with the name `platformGlobalNodeStart`
12. Add by pipeline, Pm2 Instances in the keyvault with the name `platformGlobalPm2Instances`
13. Add by pipeline, Pm2 Execution Mode in the keyvault with the name `platformGlobalPm2ExecMode`
14. Add by pipeline, the Organisations Database Name in the keyvault with the name `platformGlobalOrganisationsDatabaseName`
15. Add by pipeline, Directories Database Name in the keyvault with the name `platformGlobalDirectoriesDatabaseName`
16. Add the user Feedback Url in the keyvault with the name `platformGlobalUserFeedbackUrl` 
17. Add a support Email Address in the keyvault with the name `supportEmailAddress` 
18. Add service Now url in the keyvault with the name `SNContactUrl`
19. Add Google Analytics ID in the keyvault with the name `googleAnalyticsID`
20. Add gias settings in the keyvault with the name `giasSettings`
21. Add the gias service username in the keyvault with the name `giasServiceUsername`
22. Add the gias service url in the keyvault with the name `giasServiceUrl`
23. Add the gias service password in the keyvault with the name `giasServicePassword`
24. Add the gias application id in the keyvault with the name `giasApplicationId`
25. Add the gias Data url in the keyvault with the name `giasAllGroupsDataUrl`
26. Add the fe connect url for access the manage your education and skills funding in the keyvault with the name `feConnectUrl` 
27. Add the Notify key for SMS `GovNotify` in the keyvault with the name `NotifyKey`
28. Add the Banner base on the environment in the keyvault with the name `environmentBannerMessage`
29. Add the session secret for interaction in the keyvault with the name `sessionSecret`
30. Add the session encryption secret for interaction  in the keyvault with the name `sessionEncryptionSecret`
31. Add the crypto Private Key that used by interactions in the keyvault with the name `cryptoPublicKey`
32. Add the crypto Private Key that used by interactions in the keyvault with the name `cryptoPrivateKey`
33. Add the corona form redirect url in the keyvault with the name `coronaFormRedirectUrl`
34. Add the client secret for help  after the enteries added in database in the keyvault with the name `helpClientSecret`
35. Add the assertions secret  after the enteries added in database in the keyvault with the name `assertionsSecret`
36. Add the afroms client  after the enteries added in database secret in the keyvault with the name `afromsClientSecret`
37. Add the afroms client id  after the enteries added in database in the keyvault with the name `afromsClientId`
38. Add the aforms setting in the keyvault with the name `aformsSetting`
39. Add the asp setting in the keyvault with the name `aspSettings`
40. Add the s2s setting in the keyvault with the name `s2sSettings`
41. Add the collect setting in the keyvault with the name `collectSettings`
42. Add the webhook of slack channel `dfe_sign_in_deployments`   in the keyvault with the name`uriSlack`

### Certificates
--- 
For adding the certificate for the Front Door
1. Add Certificate Authority in Keyvault following this [Doc](https://learn.microsoft.com/en-us/azure/key-vault/certificates/how-to-integrate-certificate-authority)
2. If certificates were not generated before
   1. Click Generate/Import in the certificate section in KeyVault
   2. Add the name
   3. Select Certificate Authority from step 1
   4. Add your first DNS like that `CN=exampole.com`
   5. Add the rest DNS Names
   6. Set Validity Period in 12 months
   7. Set Content Type Based on the team's needs
   8. Set Lifetime Action type Based on the team's needs
   9. Set Percentage Lifetime Based on the team's needs to get alerted 
   10. Set Advanced Policy Configuration based on the team's needs
   11. Click Create
3. If certificates generated before
   1. Click Generate/Import in the certificate section in KeyVault
   2. Select import in Methods of certificate creation
   3. Add the name
   4. Upload the certificate file
   5. Add Password if needed
   6. Click Create
4. Update the azure-pipelines-gw.yml to have the name of the certificate if is a Change in the value `sslCertificateName`

For more info look [here](https://learn.microsoft.com/en-us/azure/key-vault/certificates/create-certificate-signing-request?tabs=azure-portal)

## Set Variable group
---

How to Set the variable group [here](https://github.com/DFE-Digital/login.dfe.devops/blob/main/Docs/VariableGroupSecrets.md)

## Next Pipelines 
---
P.S All below pipelines except the Front door flow can show [here](https://github.com/DFE-Digital/login.dfe.devops/blob/main/Docs/PipelineFlow.md)
P.S For Access, Directory, applications, Organasation, organasation-worker, search, search-worker & Jobs you need to run Infrastructure first and will see that the task `Add Web Ip Access restriction for backend & mid tier` will fail but the `Create infrastructure` will run. Then run the full pipeline

1. Front Door Pipeline [Document](https://github.com/DFE-Digital/login.dfe.devops/blob/main/Docs/FrontDoor;.md)
2. ui.toole.kit & audit-logger
3. Access, Directory & applications 
4. Organasation, organasation-worker, search & search-worker
5. Jobs
6. Oidc & interaction 
7. Service
8. Help, profile, support, public-api & manage
9. Saml-assertions
10. All Saml services (Aform, asp, collect, dqt, gias, s2s)
11. DataFactory [Document](https://github.com/DFE-Digital/login.dfe.datafactory.reporting/blob/main/README.md)
