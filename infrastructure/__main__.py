"""An AWS Python Pulumi program"""

import pulumi
import modules.s3 as s3

config = pulumi.Config()

project_tags = {
    "project": pulumi.get_project(),
    "owner": config.require("owner")
}

##### S3 Buckets #####

# Define buckets for the project.
data_bucket = s3.define_s3_data_bucket(project_tags)
targets_bucket = s3.define_s3_targets_bucket(project_tags)

# Export the name of the buckets.
pulumi.export('data_bucket_name', data_bucket.id)
pulumi.export('targets_bucket_name', targets_bucket.id)

##### IAM Roles #####