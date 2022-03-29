"""An AWS Python Pulumi program"""

import pulumi
import modules.s3 as s3
import modules.iam as iam

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
oidc_provider = iam.define_oidc_provider(project_tags)
assume_role_policy = iam.define_assume_role_policy(oidc_provider, config.require("repository_name"))
s3_role, s3_role_policy = iam.define_s3_role(assume_role_policy, data_bucket.arn, targets_bucket.arn, project_tags)

pulumi.export('s3_role_arn', s3_role.arn)