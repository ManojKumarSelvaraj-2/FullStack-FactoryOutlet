# Createing the Group

resource "aws_iam_group" "factory_outlet_frontend_developer_group" {
  name = var.group_name
}

# Locals

locals {
  technologies = [
    "React", "Terraform", "AWS S3", "AWS CodePipeline", "AWS CodeBuild", 
    "AWS SecretsManager", "AWS EC2", "AWS Route53", "AWS CloudFront", 
    "AWS VPC", "AWS CloudWatch", "AWS SNS", "AWS EFS", "AWS EBS", 
    "AWS STSVPN", "AWS Console"
  ]
}

# Creating the user with tag values

resource "aws_iam_user" "factory_outlet_frontend_developer" {
  name = var.user_name
  tags = {
    for tech in local.technologies :
    "Technologies_And_Services_${tech}" => tech
  }
}


# Attaching the user to Group

resource "aws_iam_user_group_membership" "factory_outlet_frontend_developer1_to_group" {
  user  = aws_iam_user.factory_outlet_frontend_developer.name
  groups  = [aws_iam_group.factory_outlet_frontend_developer_group.name]
}

# Granting Console Access to The user

resource "aws_iam_user_login_profile" "factory_outlet_frontend_developer_login" {
  user    = aws_iam_user.factory_outlet_frontend_developer.name
  # password = "Dummy" # This is managed automatically by AWS and its not allowed in terraform.
  password_reset_required = true  # Set to true if you want the user to change the password on first login
}

/*

When you create an IAM user in AWS, 
the system does not automatically send an email to the user with login details unless you explicitly configure it. 
AWS will not send any login credentials by default.
https://<account-id>.signin.aws.amazon.com/console.

*/

resource "aws_iam_policy" "EcrAccessPolicy" {
  name = "ECRPolicy"
  description = "Policy to allow creating ECR, CodeBuild, and EC2 resources with least privilege"
  

  # Here we restrict permissions to only the specific actions required
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:CreateRepository",
        "ecr:DeleteRepository",
        "ecr:DescribeRepositories",
        "ecr:DescribeImages",
        "ecr:GetDownloadUrlForLayer",
        "ecr:ListTagsForResource",
        "ecr:TagResource",
        "ecr:PutImage",
        "ecr:SetRepositoryPolicy",
        "ecr:InitiateLayerUpload",
        "ecr:UploadLayerPart",
        "ecr:CompleteLayerUpload",
        "ecr:GetRepositoryPolicy"
        ]
        Resource = "*"
      }
    ]
  })
}


resource "aws_iam_policy" "code_star_user_policy" {
  name        = "CodeStarConnectionsPolicy"
  description = "Policy for CodeStar connections to GitHub"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "codestar-connections:CreateConnection",
          "codestar-connections:DeleteConnection",
          "codestar-connections:ListConnections",
          "codestar-connections:GetConnection",
          "codestar-connections:UpdateConnection"
        ]
        Resource = "*"
      }
    ]
  })
}


resource "aws_iam_policy" "Secrets_Full_Access" {
  name = "UserSecrestManagerPolicy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {Sid = "SecretsFullFullaccess",
      Effect = "Allow",
      Action = "secretsmanager:*",
      Resource = "*"
      }
    ]
  })
}
resource "aws_iam_policy" "UserCloudWatchFullAccess" {
  name        = "UserCloudWatchFullAccess"
  description = "Policy to provide full access to CloudWatch for users"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "CloudWatchFullAccess",
        Effect = "Allow",
        Action = [
          "cloudwatch:*",
          "logs:*"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_policy" "UserCodeBuildCodePipelineS3Access" {
  name        = "UserCodeBuildCodePipelineS3Access"
  description = "Policy for users to manage CodeBuild and CodePipeline"
  
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "CodePipelineMinimalAccess",
        Effect = "Allow",
        Action = [
          "codepipeline:List*",
          "codepipeline:Get*",
          "codepipeline:StartPipelineExecution",
          "codepipeline:CreatePipeline",
          "codepipeline:TagResource",
          
          ],
        Resource = "*"
      },
      {
        Sid    = "CodePipelineFullAccess",
        Effect = "Allow",
        Action = [
          "codepipeline:AcknowledgeJob",
          "codepipeline:AcknowledgeThirdPartyJob",
          "codepipeline:Create*",
          "codepipeline:Delete*",
          "codepipeline:DeregisterWebhookWithThirdParty",
          "codepipeline:Disable*",
          "codepipeline:Enable*",
          "codepipeline:OverrideStageCondition",
          "codepipeline:PollForJobs",
          "codepipeline:PollForThirdPartyJobs",
          "codepipeline:Put*",
          "codepipeline:RegisterWebhookWithThirdParty",
          "codepipeline:RetryStageExecution",
          "codepipeline:RollbackStage",
          "codepipeline:StopPipelineExecution",
          "codepipeline:TagResource",
          "codepipeline:UntagResource",
          "codepipeline:Update*",
          ],
        Resource = "*",
        Condition = {
          "StringEquals": {
            "aws:ResourceTag/OwnerGroup": "FactoryOulet-Frontend"
          }
      }
      },
      {
        Sid       = "CodeBuildMinimalAccess",
        Effect    = "Allow",
        Action    = [ "codebuild:BatchGetBuildBatches",
                      "codebuild:BatchGetBuilds",
                      "codebuild:BatchGetProjects",
                      "codebuild:BatchGetReportGroups",
                      "codebuild:BatchGetReports",
                      "codebuild:DescribeCodeCoverages",
                      "codebuild:DescribeTestCases",
                      "codebuild:GetResourcePolicy",
                      "codebuild:ListBuilds",
                      "codebuild:ListProjects",
                      "codebuild:StartBuild",
                      "codebuild:Start*",
                      "codebuild:BatchGet*",
                      "codebuild:List*",
                      "codebuild:CreateProject"
                    ]
        Resource  = "*"
      },
      {
        Sid       = "CodeBuildFullAccess",
        Effect    = "Allow",
        Action    = [ "codebuild:StopBuildBatch",
                      "codebuild:RetryBuild",
                      "codebuild:RetryBuildBatch",
                      "codebuild:CreateProject",
                      "codebuild:UpdateProject",
                      "codebuild:DeleteProject",
                      "codebuild:BatchGetBuildBatches",
                      "codebuild:BatchGetReports",
                      "codebuild:BatchPutCodeCoverages",
                      "codebuild:BatchPutTestCases",
                      "codebuild:PutResourcePolicy",
                      "codebuild:DeleteResourcePolicy",
                      "codebuild:DeleteOAuthToken",
                      "codebuild:PersistOAuthToken",
                      "codebuild:ImportSourceCredentials",
                      "codebuild:DeleteProject",
                      "codebuild:DeleteReport",
                      "codebuild:DeleteWebhook",
                      "codebuild:DescribeCodeCoverages",
                      "codebuild:GetReportGroupTrend",
                      "codebuild:ListReportsForReportGroup",
                      "codebuild:Delete*",
                      "codebuild:Update*",
                      "codebuild:Stop*",
                      "codebuild:BatchDeleteBuilds",
                      "codebuild:Create*",
                      "codebuild:BatchGetFleets",
                      "codebuild:InvalidateProjectCache"
                    ],
        Resource  = "*",
        Condition = {
          "StringEquals": {
            "aws:ResourceTag/OwnerGroup": "FactoryOulet-Frontend"
          }
      }
    },
    {
      Sid = "S3FullAccess"
      Effect = "Allow",
      Action = ["S3:Get*",
                "S3:List*",
                "S3:Describe*",
                "S3:CreateBucket",
                "s3:PutBucketTagging",
                "S3:PutBucketPolicy"],
      Resource = "*"
    },
        {
      Sid = "S3MinimalAccess"
      Effect = "Allow",
      Action = ["s3:PutObject",
        "s3:GetObject",
        "s3:DeleteObject",
        "s3:AbortMultipartUpload",
        "s3:ListBucket",
        "s3:GetBucketLocation",
        "s3:GetObjectTagging",
        "s3:PutObjectTagging",
        "s3:DeleteObjectTagging",
        "s3:RestoreObject",
        "s3:DeleteBucket",
        "s3:DeleteBucketPolicy",
        "s3:PutBucketWebsite",
        "s3:PutBucketVersioning",
        "s3:PutBucketPublicAccessBlock",
        "s3:PutBucketPolicy"
                ],
      Resource = "arn:aws:s3:::factoryoulet-front-end-host",
    },
    {
      Sid = "IAMPASS"
      Effect = "Allow"
      Action = "Iam:PassRole"
      Resource = "*"
    }
  ]
})
}

resource "aws_iam_policy" "DynamoDB_Access" {
  name        = "DynamoDBcreate"
  description = "This policy will give access to create view and use DynamoDB except destroying other users' tables"
  
  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Sid       = "DynoDBMinimalAccess",
        Effect    = "Allow",
        Action    = [
          "dynamodb:GetShardIterator",
          "dynamodb:Scan",
          "dynamodb:Query",
          "dynamodb:DescribeStream",
          "dynamodb:GetRecords",
          "dynamodb:ListStreams",
          "dynamodb:BatchGetItem",
          "dynamodb:ConditionCheckItem",
          "dynamodb:DescribeTable",
          "dynamodb:GetItem",
          "dynamodb:DescribeBackup",
          "dynamodb:DescribeContinuousBackups",
          "dynamodb:DescribeContributorInsights",
          "dynamodb:DescribeEndpoints",
          "dynamodb:DescribeExport",
          "dynamodb:DescribeGlobalTable",
          "dynamodb:DescribeGlobalTableSettings",
          "dynamodb:DescribeImport",
          "dynamodb:DescribeKinesisStreamingDestination",
          "dynamodb:DescribeLimits",
          "dynamodb:DescribeReservedCapacity",
          "dynamodb:DescribeReservedCapacityOfferings",
          "dynamodb:DescribeTableReplicaAutoScaling",
          "dynamodb:DescribeTimeToLive",
          "dynamodb:GetAbacStatus",
          "dynamodb:ListTagsOfResource",
          "dynamodb:PartiQLSelect",
          "dynamodb:ListBackups",
          "dynamodb:ListContributorInsights",
          "dynamodb:ListExports",
          "dynamodb:ListGlobalTables",
          "dynamodb:ListImports",
          "dynamodb:ListTables",
          "dynamodb:CreateTable",
          "dynamodb:TagResource"
        ],
        Resource  = "*"
      },
      {
        Sid       = "DynoDBFullccAess",
        Effect    = "Allow",
        Action    = [
          "dynamodb:GetShardIterator",
          "dynamodb:Scan",
          "dynamodb:Query",
          "dynamodb:DescribeStream",
          "dynamodb:GetRecords",
          "dynamodb:ListStreams",
          "dynamodb:BatchGetItem",
          "dynamodb:BatchWriteItem",
          "dynamodb:ConditionCheckItem",
          "dynamodb:PutItem",
          "dynamodb:DescribeTable",
          "dynamodb:DeleteItem",
          "dynamodb:GetItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteTable",
          "dynamodb:GetResourcePolicy",
          "dynamodb:CreateBackup",
          "dynamodb:CreateGlobalTable",
          "dynamodb:CreateTable",
          "dynamodb:CreateTableReplica",
          "dynamodb:DeleteBackup",
          "dynamodb:DeleteTableReplica",
          "dynamodb:DisableKinesisStreamingDestination",
          "dynamodb:EnableKinesisStreamingDestination",
          "dynamodb:ExportTableToPointInTime",
          "dynamodb:ImportTable",
          "dynamodb:PartiQLDelete",
          "dynamodb:PartiQLInsert",
          "dynamodb:PartiQLUpdate",
          "dynamodb:PurchaseReservedCapacityOfferings",
          "dynamodb:RestoreTableFromAwsBackup",
          "dynamodb:RestoreTableFromBackup",
          "dynamodb:RestoreTableToPointInTime",
          "dynamodb:StartAwsBackupJob",
          "dynamodb:TagResource",
          "dynamodb:UntagResource",
          "dynamodb:UpdateContinuousBackups",
          "dynamodb:UpdateContributorInsights",
          "dynamodb:UpdateGlobalTable",
          "dynamodb:UpdateGlobalTableSettings",
          "dynamodb:UpdateGlobalTableVersion",
          "dynamodb:UpdateKinesisStreamingDestination",
          "dynamodb:UpdateTable",
          "dynamodb:UpdateTableReplicaAutoScaling",
          "dynamodb:UpdateTimeToLive",
          "dynamodb:DeleteResourcePolicy",
          "dynamodb:PutResourcePolicy",
          "dynamodb:UpdateAbacStatus"
        ],
        Resource  = "arn:aws:dynamodb:*:*:table/*",
        Condition = {
          "StringEquals": {
            "aws:ResourceTag/OwnerGroup": "FactoryOulet-Frontend"
          }
      }
      }
    ]
  })
}

# EC2 Role and User Policy

resource "aws_iam_policy" "EC2_Read_Only" {
  name        = "EC2_Read_Only"
  description = "Read-only access to EC2 instances"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "EC2MinimalAccess"
        Effect   = "Allow",
        Action   = [
          "ec2-instance-connect:SendSSHPublicKey",    # This is important
          "ec2:StartInstances",
          "ec2:StopInstances",
          "ec2:Connect",
          "ec2:Get*",
          "ec2:Describe*",
          "ec2:List*"

        ],
        Resource = "*"
      },{
        Effect = "Allow",
        Action = "elasticloadbalancing:Describe*",
        Resource = "*",
      },
              {
            Effect = "Allow",
            Action = [
                "cloudwatch:ListMetrics",
                "cloudwatch:GetMetricStatistics",
                "cloudwatch:Describe*"
            ],
            Resource = "*"
        },
        {
            Effect = "Allow",
            Action = "autoscaling:Describe*",
            Resource = "*"
        }
    ]
  })
}

resource "aws_iam_policy" "EC2LaunchandConnect_Policy" {
  name        = "EC2LaunchandConnect_Policy"
  description = "EC2LaunchandConnect_Policy"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "EC2LaunchAndConnect",
        Effect   = "Allow",
        Action   = [
          "ec2:LaunchInstances",
          "ec2:CreateSecurityGroup",            
          "ec2:DescribeKeyPairs",
          "ec2:ModifyInstanceAttribute",
          "ec2:DeleteSecurityGroup", 
          "ec2:RevokeSecurityGroupIngress",
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:RunInstances",
          "ec2:CreateTags",
          "ec2:CreateVpc",
          "ec2:Create*"                  
        ],
        Resource = "*"
      },
      {
        Sid = "EC2DeleteAccess"
        Effect   = "Allow",
        Action   = [
          "ec2:Delete*",
        ],
        Resource = "*",
                Condition = {
          "StringEquals": {
            "aws:ResourceTag/OwnerGroup": "FactoryOulet-Frontend"
          }
      }
      }
    ]
  })
}

resource "aws_iam_policy" "codebuild_ecr_policy" {
  name   = "CodeBuildECRPolicy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "ecr:GetAuthorizationToken",  
          "ecr:BatchCheckLayerAvailability",  
          "ecr:BatchGetImage",  
          "ecr:PutImage",  
          "s3:PutObject", 
          "ecr:GetDownloadUrlForLayer"
        ]
        Resource = "*"
      }
    ]
  })
}


#S3 Role Policy

resource "aws_iam_policy" "S3_policy" {
  name        = "S3Policy"
  description = "Policy for CodePipeline to access specific S3 bucket"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow",
        Action    = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListAllMyBuckets"
        ],
        Resource  = "*",
      }
    ]
  })
}

# CodeBuild Access

resource "aws_iam_policy" "Codebuild_policy" {
  name        = "CodeBuildPolicy"
  description = "Policy for CodePipeline to trigger builds in CodeBuild"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "codebuild:StartBuild",
          "codebuild:BatchGetBuilds",
          "codebuild:BatchGetProjects",
          "codebuild:ListBuilds",
          "codebuild:ListProjects",
          "codebuild:ListReportGroups",
          "codebuild:ListCuratedEnvironmentImages",
          "codebuild:RetryBuild",
          "codebuild:StopBuild",
          "ec2:DeleteNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:CreateNetworkInterface"
        ],
        Resource = "*"
      }
    ]
  })
}

#CodePipeline Access Policy

resource "aws_iam_policy" "Codepipeline_policy" {
  name        = "CodePipelinePolicy"
  description = "Policy for CodeBuild to interact with CodePipeline"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow",
        "Action": [
        "codepipeline:PollForJobs",
        "codepipeline:GetJobDetails",
        "codepipeline:PutJobSuccessResult",
        "codepipeline:PutJobFailureResult",
        "codepipeline:StartPipelineExecution",
        "codepipeline:GetPipelineState",
        "codepipeline:GetPipeline",
        "ec2:DeleteNetworkInterface",
        "ec2:DescribeNetworkInterfaces",
        "ec2:CreateNetworkInterface"
      ],
        Resource  = "*"
      },
      {
        Effect    = "Allow",
        Action    = "codepipeline:PutJobFailureResult",
        Resource  = "*"
      }
    ]
  })
}

#Pass Role Policy

resource "aws_iam_policy" "iam_pass_role_policy" {
  name        = "PassRolePolicy"
  description = "Policy to allow CodePipeline to pass roles to CodeBuild"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow",
        Action    = "iam:PassRole",
        Resource  = "*"
      }
    ]
  })
}

resource "aws_iam_policy" "CodeBuild_Cloudwatch_policy" {
  name        = "CodeBuildCloudWatchPolicy"
  description = "Policy for CodeBuild to interact with CloudWatch Logs"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow",
        Action    = [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:CreateLogGroup"
        ],
        Resource  = "arn:aws:logs:*:*:log-group:/aws/codebuild/*"
      }
    ]
  })
}

resource "aws_iam_policy" "Codepipeline_cloudwatch_policy" {
  name        = "CodePipelineCloudWatchPolicy"
  description = "Policy for CodePipeline to interact with CloudWatch Logs"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow",
        Action    = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource  = "arn:aws:logs:*:*:log-group:/aws/codepipeline/*"
      }
    ]
  })
}

#Policy for Secrets Manager


resource "aws_iam_policy" "secrets_manager_policy" {
  name        = "SecretsManagerAccessPolicy"
  description = "Policy to allow access to specific secrets in Secrets Manager"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "SecretsManagerReadAccess",
        Effect    = "Allow",
        Action    = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
          "secretsmanager:ListSecrets"
        ],
        Resource  =  "*"
      }
    ]
  })
}

resource "aws_iam_policy" "codestar_permission" {
  name        = "CodePipelineGitHubPermission"
  description = "Permissions for CodePipeline to interact with GitHub via CodeStar Connections"
  
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AllowGitHubConnectionAccess",
        Effect = "Allow",
        Action = [
          "codestar-connections:UseConnection",
          "codestar-connections:DescribeConnection",
          "codestar-connections:ListConnections"
        ],
        Resource = "*"
      }
    ]
  })
}

# IAM Role for CodePipeline
resource "aws_iam_role" "code_pipeline_role" {
  name = "codepipeline-service-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow",
        Principal = {
          Service = ["codepipeline.amazonaws.com"] 
        },
        Action   = "sts:AssumeRole"
      }
    ]
  })
}

# IAM Policy Attachment for CodePipeline Role (S3 Policy)
resource "aws_iam_policy_attachment" "code_pipeline_s3_policy_attachment" {
  name       = "codepipeline-s3-policy-attachment"
  policy_arn = aws_iam_policy.S3_policy.arn
  roles      = [aws_iam_role.code_pipeline_role.id]

  depends_on = [aws_iam_policy.S3_policy, aws_iam_role.code_pipeline_role]
}

# IAM Policy Attachment for CodePipeline Role (Codebuild Policy)
resource "aws_iam_policy_attachment" "code_pipeline_codebuild_policy_attachment" {
  name       = "codepipeline-codebuild-policy-attachment"
  policy_arn = aws_iam_policy.Codebuild_policy.arn
  roles      = [aws_iam_role.code_pipeline_role.id]

  depends_on = [aws_iam_policy.Codebuild_policy, aws_iam_role.code_pipeline_role]
}

# IAM Policy Attachment for CodePipeline Role (IAM Pass Role Policy)
resource "aws_iam_policy_attachment" "code_pipeline_iam_pass_role_policy_attachment" {
  name       = "codepipeline-iam-pass-role-policy-attachment"
  policy_arn = aws_iam_policy.iam_pass_role_policy.arn
  roles      = [aws_iam_role.code_pipeline_role.id]

  depends_on = [aws_iam_policy.iam_pass_role_policy, aws_iam_role.code_pipeline_role]
}

# IAM Policy Attachment for CodePipeline Role (CloudWatch Policy)
resource "aws_iam_policy_attachment" "code_pipeline_cloudwatch_policy_attachment" {
  name       = "codepipeline-cloudwatch-policy-attachment"
  policy_arn = aws_iam_policy.Codepipeline_cloudwatch_policy.arn
  roles      = [aws_iam_role.code_pipeline_role.id]

  depends_on = [aws_iam_policy.Codepipeline_cloudwatch_policy, aws_iam_role.code_pipeline_role]
}

# IAM Policy Attachment for CodePipeline Role (Secrets Manager Policy)
resource "aws_iam_policy_attachment" "code_pipeline_secrets_manager_policy_attachment" {
  name       = "codepipeline-secrets-manager-policy-attachment"
  policy_arn = aws_iam_policy.secrets_manager_policy.arn
  roles      = [aws_iam_role.code_pipeline_role.id]

  depends_on = [aws_iam_policy.secrets_manager_policy, aws_iam_role.code_pipeline_role]
}

# IAM Policy Attachment for CodePipeline Role (EC2 Read-Only Policy)
resource "aws_iam_policy_attachment" "code_pipeline_ec2_read_only_policy_attachment" {
  name       = "codepipeline-ec2-read-only-policy-attachment"
  policy_arn = aws_iam_policy.EC2_Read_Only.arn
  roles      = [aws_iam_role.code_pipeline_role.id]

  depends_on = [aws_iam_policy.EC2_Read_Only, aws_iam_role.code_pipeline_role]
}

# IAM Policy Attachment for CodePipeline Role (CodeStar Permission Policy)
resource "aws_iam_policy_attachment" "code_pipeline_codestar_permission_policy_attachment" {
  name       = "codepipeline-codestar-permission-policy-attachment"
  policy_arn = aws_iam_policy.codestar_permission.arn
  roles      = [aws_iam_role.code_pipeline_role.id]

  depends_on = [aws_iam_policy.codestar_permission, aws_iam_role.code_pipeline_role]
}



# IAM Policy Attachment for CodePipeline Role (ecr_policy)
resource "aws_iam_policy_attachment" "code_pipeline_ECR_policy_attachment" {
  name       = "codepipeline-ECR-permission-policy-attachment"
  policy_arn = aws_iam_policy.codebuild_ecr_policy.arn
  roles      = [aws_iam_role.code_pipeline_role.id]

  depends_on = [aws_iam_policy.codebuild_ecr_policy, aws_iam_role.code_pipeline_role]
}

# IAM Role for CodeBuild
resource "aws_iam_role" "codebuild_service_role" {
  name = "codebuild-service-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
        Action   = "sts:AssumeRole"
      }
    ]
  })
}

# IAM Policy Attachment for CodeBuild Role (S3 Policy)
resource "aws_iam_policy_attachment" "codebuild_s3_policy_attachment" {
  name       = "codebuild-s3-policy-attachment"
  policy_arn = aws_iam_policy.S3_policy.arn
  roles      = [aws_iam_role.codebuild_service_role.id]

  depends_on = [aws_iam_policy.S3_policy, aws_iam_role.codebuild_service_role]
}

# IAM Policy Attachment for CodeBuild Role (CodePipeline Policy)
resource "aws_iam_policy_attachment" "codebuild_codepipeline_policy_attachment" {
  name       = "codebuild-codepipeline-policy-attachment"
  policy_arn = aws_iam_policy.Codepipeline_policy.arn
  roles      = [aws_iam_role.codebuild_service_role.id]

  depends_on = [aws_iam_policy.Codepipeline_policy, aws_iam_role.codebuild_service_role]
}

# IAM Policy Attachment for CodeBuild Role (IAM Pass Role Policy)
resource "aws_iam_policy_attachment" "codebuild_iam_pass_role_policy_attachment" {
  name       = "codebuild-iam-pass-role-policy-attachment"
  policy_arn = aws_iam_policy.iam_pass_role_policy.arn
  roles      = [aws_iam_role.codebuild_service_role.id]

  depends_on = [aws_iam_policy.iam_pass_role_policy, aws_iam_role.codebuild_service_role]
}

# IAM Policy Attachment for CodeBuild Role (CloudWatch Policy)
resource "aws_iam_policy_attachment" "codebuild_cloudwatch_policy_attachment" {
  name       = "codebuild-cloudwatch-policy-attachment"
  policy_arn = aws_iam_policy.CodeBuild_Cloudwatch_policy.arn
  roles      = [aws_iam_role.codebuild_service_role.id]

  depends_on = [aws_iam_policy.CodeBuild_Cloudwatch_policy, aws_iam_role.codebuild_service_role]
}

# IAM Policy Attachment for CodeBuild Role (Secrets Manager Policy)
resource "aws_iam_policy_attachment" "codebuild_secrets_manager_policy_attachment" {
  name       = "codebuild-secrets-manager-policy-attachment"
  policy_arn = aws_iam_policy.secrets_manager_policy.arn
  roles      = [aws_iam_role.codebuild_service_role.id]

  depends_on = [aws_iam_policy.secrets_manager_policy, aws_iam_role.codebuild_service_role]
}

# IAM Policy Attachment for CodeBuild Role (EC2 Read-Only Policy)
resource "aws_iam_policy_attachment" "codebuild_ec2_read_only_policy_attachment" {
  name       = "codebuild-ec2-read-only-policy-attachment"
  policy_arn = aws_iam_policy.EC2_Read_Only.arn
  roles      = [aws_iam_role.codebuild_service_role.id]

  depends_on = [aws_iam_policy.EC2_Read_Only, aws_iam_role.codebuild_service_role]
}

# IAM Policy Attachment for CodeBuild Role (CodeStar Permission Policy)
resource "aws_iam_policy_attachment" "codebuild_codestar_permission_policy_attachment" {
  name       = "codebuild-codestar-permission-policy-attachment"
  policy_arn = aws_iam_policy.codestar_permission.arn
  roles      = [aws_iam_role.codebuild_service_role.id]

  depends_on = [aws_iam_policy.codestar_permission, aws_iam_role.codebuild_service_role]
}

# IAM Policy Attachment for CodeBuild Role (EC2LaunchandConnect_Policy)
resource "aws_iam_policy_attachment" "codebuild_EC2LaunchandConnect_Policy_attachment" {
  name       = "codebuild-EC2LaunchandConnect_Policy-attachment"
  policy_arn = aws_iam_policy.EC2LaunchandConnect_Policy.arn
  roles      = [aws_iam_role.codebuild_service_role.id]

  depends_on = [aws_iam_policy.EC2LaunchandConnect_Policy, aws_iam_role.codebuild_service_role]
}


# IAM Policy Attachment for CodeBuild Role (codebuild_ecr_policy)
resource "aws_iam_policy_attachment" "codebuild_ecr_policy_attachment" {
  name       = "codebuild_ecr_policy-attachment"
  policy_arn = aws_iam_policy.codebuild_ecr_policy.arn
  roles      = [aws_iam_role.codebuild_service_role.id]

  depends_on = [aws_iam_policy.codebuild_ecr_policy, aws_iam_role.codebuild_service_role]
}

# IAM Policy Attachment for CodeBuild Role (AmazonEC2ContainerRegistryReadOnly )
resource "aws_iam_policy_attachment" "AmazonEC2ContainerRegistryReadOnly_attachment" {
  name       = "codebuild_AmazonEC2ContainerRegistryReadOnly-attachment"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  roles      = [aws_iam_role.codebuild_service_role.id]
}

# IAM Group Policy Attachment for DynamoDB Policy
resource "aws_iam_group_policy_attachment" "Attach_EC2_Read_Only" {
  policy_arn = aws_iam_policy.EC2_Read_Only.arn
  group      = aws_iam_group.factory_outlet_frontend_developer_group.name

  depends_on = [aws_iam_policy.EC2_Read_Only]
}

# IAM Group Policy Attachment for CodeBuild CodePipeline Access
resource "aws_iam_group_policy_attachment" "Attach_CodeBuild_CodePipeline_Access" {
  policy_arn = aws_iam_policy.UserCodeBuildCodePipelineS3Access.arn
  group      = aws_iam_group.factory_outlet_frontend_developer_group.name

  depends_on = [aws_iam_policy.UserCodeBuildCodePipelineS3Access]
}

# IAM Group Policy Attachment for DynamoDB Access
resource "aws_iam_group_policy_attachment" "Attach_DynamoDB_Access" {
  policy_arn = aws_iam_policy.DynamoDB_Access.arn
  group      = aws_iam_group.factory_outlet_frontend_developer_group.name

  depends_on = [aws_iam_policy.DynamoDB_Access]
}

# IAM Group Policy Attachment for Secrets Full Access
resource "aws_iam_group_policy_attachment" "Attach_Secrets_Full_Access" {
  policy_arn = aws_iam_policy.Secrets_Full_Access.arn
  group      = aws_iam_group.factory_outlet_frontend_developer_group.name

  depends_on = [aws_iam_policy.Secrets_Full_Access]
}

# IAM Group Policy Attachment for EC2 Launch and Connect Policy
resource "aws_iam_group_policy_attachment" "Attach_EC2LaunchandConnect_Policy" {
  policy_arn = aws_iam_policy.EC2LaunchandConnect_Policy.arn
  group      = aws_iam_group.factory_outlet_frontend_developer_group.name

  depends_on = [aws_iam_policy.EC2LaunchandConnect_Policy]
}

# IAM Group Policy Attachment for User CloudWatch Full Access
resource "aws_iam_group_policy_attachment" "Attach_UserCloudWatchFullAccess" {
  policy_arn = aws_iam_policy.UserCloudWatchFullAccess.arn
  group      = aws_iam_group.factory_outlet_frontend_developer_group.name

  depends_on = [aws_iam_policy.UserCloudWatchFullAccess]
}

# IAM Group Policy Attachment for CodeStar User Policy
resource "aws_iam_group_policy_attachment" "Attach_CodeStar_User_Policy" {
  policy_arn = aws_iam_policy.code_star_user_policy.arn
  group      = aws_iam_group.factory_outlet_frontend_developer_group.name

  depends_on = [aws_iam_policy.code_star_user_policy]
}


# IAM Group Policy Attachment for UserEcrPolicy
resource "aws_iam_group_policy_attachment" "EcrAccessPolicy_Attachment" {
  policy_arn = aws_iam_policy.EcrAccessPolicy.arn
  group      = aws_iam_group.factory_outlet_frontend_developer_group.name
  depends_on = [aws_iam_policy.EcrAccessPolicy]
}
