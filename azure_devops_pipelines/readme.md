# Deploy Bicep with Azure Pipelines

## Overview

## Setup Azure Devops

### Create the pipeline and repo

1. Create a devops project
2. Under repos > initialize repository and commit the source files (main.bicep and run.ps1)
3. Under Pipelines > Create new Pipeline
   1. Select where the code is (Azure repos or github)
   <img src="/doc_imgs/pipeline-step2.png" width="500" />

   2. Select Repository
   <img src="/doc_imgs/pipeline-step3.png" width="500" />

   3. Configure the pipeline with the existing ymal file
   <img src="/doc_imgs/pipeline-step4.png" width="500" />

   4. Run the pipeline
   <img src="/doc_imgs/pipeline-step5.png" width="500" />

### Create Service Connection

The service connection allows the authentication to Azure.

1. Navigate to project settings

    <img src="/doc_imgs/ServiceConn-s1.png" width="500" />
2. Select Service Connections > New Connection

    <img src="/doc_imgs/ServiceConn-s2.png" width="500" />
3. Select "Azure Resource Manager" > Pick which way you would like to authenticate with Azure

### Create Release

The release runs the bicep code and takes the input from the pipeline

1. Navigate to the release section under pipelines
2. Create new release pipeline
   
   <img src="/doc_imgs/rcp-s2.png" width="500" />
3. Configure Artifact
   
   <img src="/doc_imgs/rcp-s3.png" width="500" />
   1. Add the artifact from the pipeline
   2. Create a new stage for the bicep task




<!--- Link Ref --->
<!-- [snowflake][gh-snowflake] -->
<!-- [gh-snowflake]: https://github.com/twitter-archive/snowflake -->
<!--- Link Ref --->