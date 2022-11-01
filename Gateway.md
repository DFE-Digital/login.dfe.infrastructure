# Application Gateway for DfE Signin Services
This reposatory deploys the application gateway for DfE Signin Services. The application gateway is where all the public and private traffic will pass to reach the DfE Signin Services

P.S Until now only 5 service are under the gateway

## Audience
---
This document refers to the DevOps engineers who will maintain this pipeline.Also, the responsibility to keep this document up to date with the latest information

## Prerequizet
---
1. Subnet for the gateway
2. Certificate in the Keyvault for the identity management to link
3. If new resource group deployed with different name, CIP team needs to allow the public Ip address creation in that resource group
4. All service components that under the gateway must be deploy 

## Stages
---
1. Scan tools stage the will use checkov to scan the infrastructure
2. Deployment [enviromnent Name] that will deploy to specific enviromnent using gateway.yml that located in login.dfe.devops reposatory. The gateway.yml deploys 2 infrastructure ARM Templates that both loacted in login.dfe.devops reposatory.
   1. First ARM template will deploy the VNET using the gatewayVnet.json
   2. Second ARM template will deploy the Gateway using the gateway.json

## Post Deployment
---
1. Note the public IP address of the gateway
2. Get the listeners custom domain
3. Open Service Request on service now using this [Form](https://dfe.service-now.com.mcas.ms/serviceportal?id=sc_cat_item&sys_id=3ab186f8db2c2b403b929334ca961998&sysparm_category=19d07bc3dbff17003b929334ca9619bd)
   1. Give a short description of your request : Route 53 DNS Add/Update
   2. elect an appropriate Category: Non Standard
   3. Describe your request in as much detail as possible. If there is not enough information, your request will be placed on hold until this is received:
       ```Add/Updates for the below records:
        Hosted zone: education.gov.uk
        Record Type: Create A record
        Record name: <Record Name>.signin
        Value: <Gateway IP>

        Hosted zone: education.gov.uk
        Record Type: Create A record
        Record name: <Record Name>.signin
        Value: <Gateway IP>```

   4. Business Service: Share IT core services
   5. Service Offering: DfE Sign-in

## Test Deployment

1.	Go to the service component
2.	Select TLS/SSL Settings under the setting left site menu
3.	Checking that the TLS/SSL bindings is been empty
4.	Step 1-3 image
![1-3 images](/imgs/steps1-3.png)
5.	Open Incognito mode
6.	Go to the url of the service component 
7.	Find the Lock icon in the left site of the URL
8.	If is not red that means the Certificate is binding, if red that means the certificate was not get binding
9.	For more information click in the lock icon
10.	Click on connection secure
11.	Click on Certification is valid or not valid
12.	Step 5-9 image 
![1-3 images](/imgs/steps5-9.png)
