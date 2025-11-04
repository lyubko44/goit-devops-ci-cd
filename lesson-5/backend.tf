# УВАГА: Цей файл буде активовано ПІСЛЯ першого apply!
# 
# Кроки для налаштування backend:
# 1. Спочатку запустіть: terraform init && terraform apply
#    (це створить S3 bucket та DynamoDB table)
# 2. Розкоментуйте блок terraform нижче
# 3. Запустіть: terraform init -migrate-state
#    (це перемістить state в S3)

# terraform {
#   backend "s3" {
#     bucket         = "terraform-state-lesson-5-bucket"
#     key            = "lesson-5/terraform.tfstate"
#     region         = "us-west-1"
#     profile        = "training"
#     dynamodb_table = "terraform-locks"
#     encrypt        = true
#   }
# }

