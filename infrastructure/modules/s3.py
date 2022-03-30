import pulumi
from pulumi_aws import s3

def define_s3_data_bucket(project_tags):
    """
    Define a S3 Bucket to hold the data for the project.
    """
    bucket = define_bucket('data-bucket-', project_tags)
    return bucket

def define_s3_targets_bucket(project_tags):
    """
    Define a S3 Bucket to hold the targets metadata for the project.
    """
    bucket = define_bucket('targets-bucket-', project_tags)
    return bucket

def define_bucket(name, project_tags):
    """
    Define a S3 Bucket for the project.
    """
    bucket = s3.Bucket(name,
        acl = "private",
        bucket_prefix=name,
        tags=project_tags)
    return bucket