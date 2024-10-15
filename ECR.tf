resource "aws_ecr_repository" "ims_repo" {
  name = "ims-app"
}

resource "aws_ecr_lifecycle_policy" "ims_repo" {
  repository = aws_ecr_repository.ims_repo.name
  policy     = <<EOF
  {
    "rules": [
    {
      "rulePriority": 1,
      "description": "Keep last 30 release tagged images",
      "selection": {
        "tagStatus": "tagged",
        "tagPrefixList": ["release"],
        "countType": "imageCountMoreThan",
        "countNumber": 30
      },
      "action": {
        "type": "expire"
      }
    }
  ]
}
EOF

}