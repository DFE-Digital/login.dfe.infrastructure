# Infrastructure

This repo contains the base infrastructure for the deployment of DfE signin services.

## Audience
---
This document refers to the DevOps engineers who will maintain this pipeline. Also, the responsibility to keep this document up to date with the latest information

## Prerequisite
---
For the time this document has been created 2 prerequisites are needed before the pipeline will run

1. Azure Active Directory needs 4 App registrations that will be created by the CIP team
   1. Service connections for the pipeline to be able to deploy in all environments
   2. Azure Active Directory Admin for the use of connection in the SQL server
   3. Microsoft Azure App Service that will give access to the app services to access the key vaults
2. Personal access token from GitHub to access the private repo for the deployment 
3. Comment out the scan tool stage of the pipeline for the first time you deploy an empty subscription
4. Check the code to see if any inner dependency exists as maybe added later
5. Create 6 Variable groups
   1. dsi-global that will host all service connections names and custRegAuth for the npm library
   2. The rest 5 will be for each environment with the name `dsi-<enviroment ID>-kv` that will connect in the key vault. For the First deployment, the list of the below value must be added manually in the group variables and after moving to the respected environment key vaults.
      1. templatesBaseUri -> will be created by the preDeployInfrastrusture and added in the key vault but need to transfer to the local group for the base infrastructure deployment
      2. redisCacheSku -> The Redis Cache SKU 
      3. sqlAdministratorLogin & sqlAdministratorLoginPassword -> The cretentials for the Sql server 
      4. databaseNames -> The secret will have array of JSON with database names and the max-size bytes for example `[{"name":"dbname1","maxSizeBytes":"size"},{"name":"dbname1","maxSizeBytes":"size"}]`
      5. CHGWIP -> The IP that use to access the SQL server
      6. elasticPoolProperties -> The Elastic Pool Properties for the SQL serves
      7. environmentId -> The environment Id for the environment that the group is represents
      8. platformGlobalName -> The global platform name that uses of the name the services
      9. azureActiveDirectoryAdmin -> The name of the app registration for connectin in SQL Servers
      10. azureActiveDirectoryAdminSID -> The app registration object id for connectin in SQL Servers
      11. azureDevOpsObjectId -> The object Id of the service connection for the new key vault
      12. microsoftAzureWebsitesRPObjectId -> The object Id of the app registration for app services to connect in the key vault

## Deployes 