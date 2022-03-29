import pulumi
import pulumi_aws as aws

def define_oidc_provider(project_tags):
    return aws.iam.OpenIdConnectProvider("oidc-provider",
    client_id_lists = ["sts.amazonaws.com"],
    thumbprint_lists = ["6938fd4d98bab03faadb97b34396831e3780aea1"],
    url = "https://token.actions.githubusercontent.com",
    tags=project_tags)

def define_assume_role_policy(oidc_provider, repository_name):
    return aws.iam.get_policy_document(
        statements=[aws.iam.GetPolicyDocumentStatementArgs(
            actions=["sts:AssumeRoleWithWebIdentity"],
            effect="Allow",
            principals=[aws.iam.GetPolicyDocumentStatementPrincipalArgs(
                type="Federated",
                identifiers=[oidc_provider.arn],
            )],
            conditions=[
                aws.iam.GetPolicyDocumentStatementConditionArgs(
                    test = "StringEquals",
                    variable = "token.actions.githubusercontent.com:aud",
                    values = ["sts.amazonaws.com"]),
                aws.iam.GetPolicyDocumentStatementConditionArgs(
                    test = "StringLike",
                    variable = "token.actions.githubusercontent.com:sub",
                    values = [f"repo:{repository_name}:*"])
            ]            
        )]
    )

def define_s3_role(assume_role_policy, data_bucket_arn, targets_bucket_arn, project_tags):
    s3_role = aws.iam.Role('s3-role', 
        aws.iam.RoleArgs(
            assume_role_policy=assume_role_policy.json,
            tags = project_tags
        )
    )

    s3_role_policy = aws.iam.RolePolicy('s3-role-policy',
        role = s3_role.name,
        policy = aws.iam.get_policy_document(
            statements=[
                aws.iam.GetPolicyDocumentStatementArgs(
                    actions=["s3:GetObject",
                             "s3:ListBucket"],
                    effect="Allow",
                    resources=[data_bucket_arn]),
                aws.iam.GetPolicyDocumentStatementArgs(
                    actions=["s3:PutObject", 
                             "s3:DeleteObject", 
                             "s3:ListBucket", 
                             "s3:GetObject"],
                    effect="Allow",
                    resources=[targets_bucket_arn]),
                aws.iam.GetPolicyDocumentStatementArgs(
                    actions=["s3:*"],
                    effect="Deny",
                    resources=[data_bucket_arn, targets_bucket_arn]),
            ],
        ).json
    )

    return (s3_role, s3_role_policy)
