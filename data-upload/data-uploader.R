library(aws.s3)
source("pulumi.R")

pulumiStack <- get_stack()
pulumiDeployment <- get_deployment(pulumiStack)
pulumiResources <- get_resources(pulumiDeployment)
pulumiOutputs <- get_stack_outputs(pulumiResources)

data_bucket_name <- get_output_value(pulumiOutputs, "data_bucket_name")

aws.s3::get_bucket(bucket = data_bucket_name)
