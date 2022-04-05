library(aws.s3)

source("../data-upload/pulumi.R")

pulumiStack <- get_stack()
pulumiDeployment <- get_deployment(pulumiStack)
pulumiResources <- get_resources(pulumiDeployment)
pulumiOutputs <- get_stack_outputs(pulumiResources)

targets_bucket_name <- get_output_value(pulumiOutputs, "targets_bucket_name")

aws.s3::s3sync(bucket = targets_bucket_name)