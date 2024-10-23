data "aws_iam_policy_document" "codepipeline" {
  statement {
    effect = "Allow"
    resources = ["*"]

    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetBucketVersioning",
      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild",
      "ecs:DescribeServices",
      "ecs:DescribeTaskDefinition",
      "ecs:DescribeTasks",
      "ecs:ListTasks",
      "ecs:RegisterTaskDefinition",
      "ecs:UpdateService",
      "iam:PassRole",
    ]
  }
}

module "codepipeline_role" {
  source = "../iam_role"
  name = "codepipeline"
  identifier = "codepipeline.amazonaws.com"
  policy = data.aws_iam_policy_document.codepipeline.json
}

resource "aws_codepipeline" "ims_app" {
  name     = "ims-app"
  role_arn = module.codepipeline_role.iam_role_arn
  stage {
    name = "Source"
    action {
      category = "Source"
      name     = "ECRSource"
      owner    = "AWS"
      provider = "ECR"
      version  = "1"
      output_artifacts = ["SourceOutput"]
      configuration = {
#         RepositoryName = data.aws_ssm_parameter.ECR_REPO.value
        RepositoryName = "ims-app"
        ImageTag = "app-latest"
      }
    }
  }
  stage {
    name = "Deploy"
    action {
      category = "Deploy"
      name     = "ECSDeploy"
      owner    = "AWS"
      provider = "ECS"
      version  = "1"
      input_artifacts = ["SourceOutput"]

      configuration = {
        ClusterName = aws_ecs_cluster.ims_app.name
        ServiceName = aws_ecs_service.ims_app.name
        FileName = "imagedefinitions.json"
      }
    }
  }
  artifact_store {
    location = ""
    type     = ""
  }
}

data "aws_ssm_parameter" "ECR_REPO" {
  name = "/ims-app/ECR_REPO"
}
