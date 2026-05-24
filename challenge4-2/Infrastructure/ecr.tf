# ECR
resource "aws_ecr_repository" "api" {
  name                 = "api-container-ec2"
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = { Name = "api-ecr" }
}
