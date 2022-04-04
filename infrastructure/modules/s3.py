import pulumi
from pulumi_aws import s3

def define_bucket(name, project_tags):
    """
    Define a S3 Bucket for the project.
    """
    bucket = s3.Bucket(name,
        acl = "private",
        bucket_prefix=name,
        tags=project_tags)
    return bucket