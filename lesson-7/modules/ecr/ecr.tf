resource "aws_ecr_repository" "this" {
  name                 = var.repo_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = var.image_scan_on_push
  }

  force_delete = var.force_delete

  tags = merge(var.tags, {
    Name = var.repo_name
  })
}


