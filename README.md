# Infrastructure

This repo contains the base infrastructure for the deployment of DfE signin services.

## Audience
---
This document refers to the DevOps engineers who will maintain this pipeline.Also, the responsibility to keep this document up to date with the latest information

## Prerequizet
---
For the time of this document is been created 2 prerequizet are needed before the pipeline will run

1. Azure Activer Directory needs 4 App registrations that will created from the CIP team
   1. Service connections for the pipeline to be able to deploy in the enviroments
   2. Azure Active Directory Admin for the use of connection in the Sql server
   3. Microsoft Azure App Service that will give access to the app services to acces the keyvaults
2. Personal access token from GitHub to access the private repo for the deployemnt 
3. Comment out the scan tool stage of the pipeline for the first time you deploy in empty subscription
4. Check the code if any inner dependency exist as maybe added later
5. Create 6 Variable groups
   1. dsi-global that will host all service connections names and custRegAuth for the npm library
   2. The rest 5 will be for each enviroment with the name `dsi-<enviroment ID>-kv` that will connect in the keyvault. For the First deployment the list of the below value must be added manualy in the group variables and after move to the respected enviroment keyvaults.
      1. templatesBaseUri -> will be created be the preDeployInfrastrusture and added in the keyvault but need to transfer to the local group for the base infrastructure deployemnt
      2. redisCacheSku -> The Redis Cache Sku 
      3. sqlAdministratorLogin & sqlAdministratorLoginPassword -> The cretentials for the Sql server 
      4. databaseNames -> The secret will have array of json with database names and the maxSizeBytes for exampole `[{"name":"dbname1","maxSizeBytes":"size"},{"name":"dbname1","maxSizeBytes":"size"}]`
      5. CHGWIP -> The IP that use to acces the sql server
      6. elasticPoolProperties -> The Elastic Pool Properties for the sql serves
      7. environmentId -> The environment Id for the enviroment that the group is represents
      8. platformGlobalName -> The platform global name that use of the name the services
      9. azureActiveDirectoryAdmin -> The name of the app registration for connectin in sql Servers
      10. azureActiveDirectoryAdminSID -> The app registration object id for connectin in sql Servers
      11. azureDevOpsObjectId -> The object Id of the service connection for the new keyvault
      12. microsoftAzureWebsitesRPObjectId -> The object Id of the app registration for app services to connect in the keyvault
   