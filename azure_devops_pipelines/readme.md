# Deploy Bicep with Azure Pipelines

## Overview

## Setup Azure Devops

### Create the pipeline and repo

1. Create a devops project
2. Under repos > initialize repository and commit the source files (main.bicep and run.ps1)
3. Under Pipelines > Create new Pipeline
   1. Select where the code is (Azure repos or github)
   ![Pipeline-S2](/doc_imgs/pipeline-step2.png)
   2. Select Repository
   ![Pipeline-S3](/doc_imgs/pipeline-step3.png)
   3. Configure the pipeline with the existing ymal file
   ![Pipeline-S4](/doc_imgs/pipeline-step4.png)
   4. Run the pipeline
   ![Pipeline-S5](/doc_imgs/pipeline-step5.png)

### Create Service Connection

The service connection allows the authentication to Azure.

1. Navigate to project settings
![ServiceConn-s1](/doc_imgs/ServiceConn-s1.png)
2. Select Service Connections > New Connection
![ServiceConn-s1](/doc_imgs/ServiceConn-s2.png)
3. Select "Azure Resource Manager" > Chose Authentication method
   1. Service Principle (Automatic) - will create and assign the role 

### Create Release




<!--- Link Ref --->
[snowflake][gh-snowflake]
[gh-snowflake]: https://github.com/twitter-archive/snowflake
<!--- Link Ref --->