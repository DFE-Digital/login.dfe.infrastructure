# Infrastructure

This repo contains pre & base infrastructure for the deployment of DfE signin services.

## Audience
---
This document refers to the DevOps engineers who will maintain this pipeline. Also, the responsibility to keep this document up to date with the latest information

## Prerequisite
---

1. Azure Active Directory needs 3 App registrations that created by the DevOps team. (This Prerequisite is all ready set. This may needed when moving tenants )
   1. Service connections for the pipeline to be able to deploy in all environments. May need approvole from CIP team
   2. Azure Active Directory Admin for the use of connection in the SQL server. May need approvole from CIP team
   3. Microsoft Azure App Service that will give access to the app services to access the key vaults. May need approvole from CIP team
2. Azure Active Directory needs 2 App registrations that created by devops team.(This Prerequisite is all ready set. But for new environments they will needed)
   1. The will be the authetication for the app services with name `S141EnvId-app` how to created [here](https://github.com/DFE-Digital/login.dfe.devops/blob/feature/DSI-5680/Docs/AppRegistrations.md)
   2. The will be the authetication for the client services with name `S141EnvId-client` how to created [here](https://github.com/DFE-Digital/login.dfe.devops/blob/feature/DSI-5680/Docs/AppRegistrations.md)
   3. Add `S141EnvId-app` objectid in the keyvault with name `aadshdappid`
   4. Add `S141EnvId-client` objectid in the keyvault with name `aadshdclientid` & secret with name `aadshdclientsecret`
3. Personal access token from GitHub to access the private repo for the deployment. How to created [here](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token)
4. Comment out the scan tool stage of the pipeline for the first time you deploy an empty subscription
5. Check the code to see if any inner dependency exists as maybe added later
6. Create 6 Variable groups
   1. dsi-global that will host all service connections names and custRegAuth for the npm library
   2. The rest 5 will be for each environment with the name `dsi-<enviroment ID>-kv` that will connect in the key vault. For the First deployment, the list of the below value must be added manually in the group variables and after moving to the respected environment key vaults. This step is build two sections
      1. Pre-requzet Infrastructure
         1.  environmentId -> The environment Id for the environment that the group is represents
         2.  platformGlobalName -> The global platform name that uses the name of the services. Value: `signin`
         3.  azureDevOpsObjectId -> The object Id of the service connection Enterprise applications for the new key vault
         4.  microsoftAzureWebsitesRPObjectId -> The object Id of the Enterprise applications for app services to connect in the key vault
         5.  subscriptionId -> The subscription id of azure for the deployment
         6.  tags -> Tags that have been designated tags that have been set by the CIP team. They need to be added manualy in keyvault
      2. Base infrastructure Deployment that has been added in keyvault after the Pre-request Infrastructure pipeline runs (manually)
         1. templatesBaseUri -> will be created by the preDeployInfrastrusture and added in the keyvault but need to transfer to the local group for the base infrastructure deployment
         2. gitToken -> Personal token how to be created [here]()
         3. redisCacheSku -> The Redis Cache SKU 
         4. sqlAdministratorLogin & sqlAdministratorLoginPassword -> The cretentials for the Sql server 
         5. databaseNames -> The secret will have array of JSON with database names and the max-size bytes for example `[{"name":"dbname1","maxSizeBytes":"size"},{"name":"dbname1","maxSizeBytes":"size"}]`
         6. CHGWIP -> The IP that use to access the SQL server from DfE workstations
         7. elasticPoolSku -> The Elastic Pool sku for the SQL serves
         8. elasticPoolProperties -> The Elastic Pool Properties for the SQL serves
         9.  azureActiveDirectoryAdmin -> The name of the group for connectin in SQL Servers
         10. azureActiveDirectoryAdminSID -> The group object id for connectin in SQL Servers
         11. platformGlobalIdentifier -> The global identifier `s141`
         12. platformGlobalMinTlsVersion -> The min Tls Version `1.2`
         13. platformGlobalName -> The global name `signin`
         14. platformGlobalUserFeedbackUrl -> The User Feed back Url that will provided by the DfE team
         15. UIContainerName -> Name of the cdn container in storage account `ui-assets`
         16. cdnAssetsVersion -> Version of the cdn `1`
         17. cdnHostName -> Host of the cdn is the full endpoint with `https` includet
7. Updated parameter `deployPrivateEndpoint` from false to true for deploying all the private enpoints and after deployement changes back to false in azure-pipeline.yml
8. If new resource group deployed with different name, CIP team needs to allow the virtual Network creation in that resource group
9.  Updated variable `destructiveVirtualNetworkDeploy` from Disabled to Enabled for deploying the vnet First time and after deployement changes back to Disabled in azure-pipeline.yml
10. Check the Deploy Pre-Requisites and Enviroment you deploy in the first run for creation of the Logic app and the KeyVault.

## Deployment
---
All external files are located in login.dfe.devops 
Infrastrucuter pipeline has two satges:

1. Scan Infrastructure that will use checkov to scan the yml & ARM templates for the deployment
2. Deployment stage that is have to job under:
   1. Pre deployments Job that will create the logic app in dev enviroment and the Keyvault that will use in all the enviroment and for the variable groups in azure devops after the first run any new subscriptio or enviroment. The ARM template for that job are located in login.dfe.devops.
   2. Base infrastructure Job that will deploy all the specify componets that are diffint in the template.json under the DevOps/templates folder

More information of trigger & Approvols please check [here](https://github.com/DFE-Digital/login.dfe.devops/blob/main/Docs/PipelineTrigger.md)

Also this pipeline has an extra parameter in pipeline trigger the Pre-Requisites for deploying the pre requisites infrastructure if needed 

## Post Deployment

*All Add by pipeline secret will automaticly be added in the keyvault after pre deploy infrastrucute completes 

1. Add by pipeline, app insights instrumentation key in the keyvault with name `appInsightsInstrumentationKey`
2. Add by pipeline, audit Service Bus Subscription Name in the keyvault with name  `auditServiceBusSubscriptionName`
3. Add by pipeline, audit Service Bus Topic Name in the keyvault with name  `auditServiceBusTopicName`
4. Add by pipeline, audit Sql Database Name in the keyvault with name  `auditSqlDbName`
5. Add by pipeline, audit Sql Host Name in the keyvault with name  `auditSqlHostName`
6. Add tenant Url in the keyvault with name `tenantUrl`
7. Add by pipeline, cdn Assets Version in the keyvault with name `cdnAssetsVersion`
8. Add by pipeline, cdn Host Name in the keyvault with name `cdnHostName`
9. All Add by pipeline hosts/Urls names of the app services with the name schema `standalone<Appservice Full Name>HostName`. P.S For All frond end services use the Certificate domain/if not certificate exist for the domain use the app service default schema 
10. Add redis Connection in the keyvault with name `redisConn` & format `redis://:<primary key>@<resource name>:<port name>`
11. Add by pipeline, Node start file path in the keyvault with name `platformGlobalNodeStart`
12. Add by pipeline, Pm2 Instances in the keyvault with name `platformGlobalPm2Instances`
13. Add by pipeline, Pm2 Execution Mode in the keyvault with name `platformGlobalPm2ExecMode`
14. Add by pipeline, Organisations Database Name in the keyvault with name `platformGlobalOrganisationsDatabaseName`
15. Add by pipeline, Directories Database Name in the keyvault with name `platformGlobalDirectoriesDatabaseName`
16. Add user Feedback Url in the keyvault with name `userFeedbackUrl` 
17. Add support Email Address in the keyvault with name `supportEmailAddress` 
18. Add service Now url in the keyvault with name `SNContactUrl`
19. Add google Analytics ID in the keyvault with name `googleAnalyticsID`
20. Add gias settings in the keyvault with name `giasSettings`
21. Add gias service username in the keyvault with name `giasServiceUsername`
22. Add gias service url in the keyvault with name `giasServiceUrl`
23. Add gias service password in the keyvault with name `giasServicePassword`
24. Add gias application id in the keyvault with name `giasApplicationId`
25. Add gias Data url in the keyvault with name `giasAllGroupsDataUrl`

## Next Pipelines 
---
P.S All below pipelines except the gateway the flow can show in [here](https://github.com/DFE-Digital/login.dfe.devops/blob/main/Docs/PipelineFlow.md)

1. Gateway Pipeline [Document](Gateway.md)
2. Directory & applications Pipelines
3. Oidc & interaction Pipelines
4. Service Pipeline
5. The rest pipelines after them 