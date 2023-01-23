# Deploy Bicep with Azure Pipelines

## Overview

## Setup Azure Devops

### Create the pipeline and repo

1. Create a devops project
2. Under repos > initialize repository and commit the source files (main.bicep and run.ps1)
3. Under Pipelines
   1. Create new Pipeline
   ![Pipeline-S1](azure_devops_pipelines\img\pipeline-step1.png)
   2. Select where the code is (Azure repos or github)
   ![Pipeline-S2](azure_devops_pipelines\img\pipeline-step2.png)
   3. Select Repository
   ![Pipeline-S3](azure_devops_pipelines\img\pipeline-step3.png)
   4. Configure the pipeline with the existing ymal file
   ![Pipeline-S4](azure_devops_pipelines\img\pipeline-step4.png)
   5. Run the pipeline
   ![Pipeline-S5](azure_devops_pipelines\img\pipeline-step5.png)

[snowflake][gh-snowflake]

<!--- Link Ref --->
[gh-snowflake]: https://github.com/twitter-archive/snowflake
<!--- Link Ref --->