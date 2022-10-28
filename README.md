# Infrastructure

This repo contains the base infrastructure for the deployment of DfE signin services.

## Audience
---
This document refers to the DevOps engineers who will maintain this pipeline. Also, the responsibility to keep this document up to date with the latest information

## Prerequisite
---
For the time this document has been created 2 prerequisites are needed before the pipeline will run

1. Azure Active Directory needs 3 App registrations that will be created by the CIP team
   1. Service connections for the pipeline to be able to deploy in all environments
   2. Azure Active Directory Admin for the use of connection in the SQL server
   3. Microsoft Azure App Service that will give access to the app services to access the key vaults
2. Personal access token from GitHub to access the private repo for the deployment 
3. Comment out the scan tool stage of the pipeline for the first time you deploy an empty subscription
4. Check the code to see if any inner dependency exists as maybe added later
5. Create 6 Variable groups
   1. dsi-global that will host all service connections names and custRegAuth for the npm library
   2. The rest 5 will be for each environment with the name `dsi-<enviroment ID>-kv` that will connect in the key vault. For the First deployment, the list of the below value must be added manually in the group variables and after moving to the respected environment key vaults. This step is build two sections
      1. Pre-requzet Infrastructure
         1. environmentId -> The environment Id for the environment that the group is represents
         2.  platformGlobalName -> The global platform name that uses the name of the services
         3.  azureDevOpsObjectId -> The object Id of the service connection for the new key vault
         4.  microsoftAzureWebsitesRPObjectId -> The object Id of the app registration for app services to connect in the key vault
         5.  subscriptionId -> The subscription id of azure for the deployment
         6.  tags -> Tags that have been designated tags that have been set by the CIP team. They need to be added manualy in keyvault
      2. Base infrastructure Deployment that has been added in keyvault after the Pre-request Infrastructure pipeline runs (manually)
         1. templatesBaseUri -> will be created by the preDeployInfrastrusture and added in the keyvault but need to transfer to the local group for the base infrastructure deployment
         2. redisCacheSku -> The Redis Cache SKU 
         3. sqlAdministratorLogin & sqlAdministratorLoginPassword -> The cretentials for the Sql server 
         4. databaseNames -> The secret will have array of JSON with database names and the max-size bytes for example `[{"name":"dbname1","maxSizeBytes":"size"},{"name":"dbname1","maxSizeBytes":"size"}]`
         5. CHGWIP -> The IP that use to access the SQL server
         6. elasticPoolProperties -> The Elastic Pool Properties for the SQL serves
         7.  azureActiveDirectoryAdmin -> The name of the app registration for connectin in SQL Servers
         8.  azureActiveDirectoryAdminSID -> The app registration object id for connectin in SQL Servers
6. Updated parameter `deployPrivateEndpoint` from false to true for deployeing all the private enpoints and after deployement changes back to false
7. Check the Deploy Pre-Requisites and Enviroment you deploy in the first run for creation of the Logic app and the KeyVault. The Logic app will deploy only in the Dev environment. 

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