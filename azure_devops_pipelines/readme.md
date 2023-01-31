# Deploy Bicep with Azure Pipelines

## Overview

For IT organizations that need to deploy Azure resources from a ticketing systems. Integrating Azure Pipelines in to your service flow for a ticket is one option to speed up provisioning of standard resources or landing zones. Below shows one possible option using Bicep templates and triggered by a rest api.

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
2. Add environmental variables
 
    >**TIP**
    > Use Variable groups to store values and secrets that you might want available across multiple pipelines. You can share and use variable groups in multiple pipelines in the same project.
    
   1. Variables to add (AzRegion, AzRgPrefix, BuChargeBackCode), Check the box for 'Settable at Release'

   <img src="/doc_imgs/rcp-envvar.png" width="1000" />
3. Create new release pipeline
   
   <img src="/doc_imgs/rcp-s2.png" width="500" />
4. Configure the pipeline by adding the artifact and the powershell stage
   
   <img src="/doc_imgs/rcp-s3.png" width="500" />

   1. Select the + on the artifact box, pick the source pipeline that builds the artifact
   2. Select the + on the stage box, select empty job at the top
5. Add AzurePowershell build task
   
   <img src="/doc_imgs/rcp-stage-task-bicep.png" width="500" />
6. Configure the stage

   <img src="/doc_imgs/task-config.png" width="500" />

   1. Select the azure subscription service connection
   2. Set the script path and arguments

    ```powershell
    ## Script Path
    $(System.DefaultWorkingDirectory)/_InfastructureAsCode/drop/run.ps1

    ## Arguments 
    -AzRegion $env:AzRegion -BuChargeBackCode $env:BuChargeBackCode -AzRgPrefix $env:AzRgPrefix
    ```

   3. Under the advanced dropdown set the working directory
   
    ```powershell
    $(System.DefaultWorkingDirectory)/_InfastructureAsCode/drop
    ```

    <img src="/doc_imgs/task-workingdir.png" width="500" />

## Trigger the release

Options for triggering the pipeline

1. Manually in the Azure Devops Portal
2. Logic Apps - using the plugin for azure devops
3. Azure Rest API

### Manual Trigger in Azure Devops

1. Under the Azure DevOps Project navigate to the release section > select new release

   <img src="/doc_imgs/pipeline-cr-release1.png" width="500" />
2. On the new release section fill out the variables to be passed > select create

   <img src="/doc_imgs/pipeline-cr-release2.png" width="500" />

### RestAPI

To integrate with external systems you can trigger a release from the [Azure Rest API][restapi-releasecreate]

<!--- Link Ref --->
[restapi-releasecreate]: https://learn.microsoft.com/en-us/rest/api/azure/devops/release/releases/create?view=azure-devops-rest-7.0&tabs=HTTP
<!--- Link Ref --->