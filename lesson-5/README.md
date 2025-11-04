# Lesson 5: Terraform Infrastructure на AWS

## 📋 Опис проєкту

Цей проєкт демонструє створення повноцінної інфраструктури на AWS за допомогою Terraform з використанням модульної архітектури. Проєкт включає налаштування безпечного зберігання стейт-файлів, мережеву інфраструктуру та Container Registry для Docker-образів.

## 🏗️ Структура проєкту

```
lesson-5/
│
├── main.tf                  # Головний файл для підключення модулів
├── backend.tf               # Налаштування бекенду для стейтів (S3 + DynamoDB)
├── variables.tf             # Змінні для конфігурації
├── outputs.tf               # Загальне виведення ресурсів
├── terraform.tfvars.example # Приклад файлу зі змінними
├── .gitignore               # Файли для виключення з Git
│
├── modules/                 # Каталог з усіма модулями
│   │
│   ├── s3-backend/          # Модуль для S3 та DynamoDB
│   │   ├── s3.tf            # Створення S3-бакета з версіонуванням
│   │   ├── dynamodb.tf      # Створення DynamoDB для блокування
│   │   ├── variables.tf     # Змінні модуля
│   │   └── outputs.tf       # Виведення інформації
│   │
│   ├── vpc/                 # Модуль для VPC
│   │   ├── vpc.tf           # VPC, підмережі, Internet Gateway, NAT Gateway
│   │   ├── routes.tf        # Налаштування маршрутизації
│   │   ├── variables.tf     # Змінні модуля
│   │   └── outputs.tf       # Виведення інформації
│   │
│   └── ecr/                 # Модуль для ECR
│       ├── ecr.tf           # ECR репозиторій з lifecycle policy
│       ├── variables.tf     # Змінні модуля
│       └── outputs.tf       # Виведення URL репозиторію
│
└── README.md                # Ця документація
```

## Модулі проєкту

### 1️⃣ Модуль S3-Backend

**Призначення:** Створення S3-бакета та DynamoDB таблиці для безпечного зберігання та блокування Terraform state файлів.

**Ресурси:**
- **S3 Bucket** - зберігання state файлів
  - Версіонування увімкнене
  - Шифрування AES256
  - Блокування публічного доступу
- **DynamoDB Table** - блокування state під час одночасних операцій
  - Режим оплати: PAY_PER_REQUEST
  - Hash Key: LockID

**Виходи:**
- `s3_bucket_id` - ім'я S3 бакета
- `s3_bucket_arn` - ARN S3 бакета
- `dynamodb_table_name` - ім'я DynamoDB таблиці

### 2️⃣ Модуль VPC

**Призначення:** Створення повноцінної мережевої інфраструктури з публічними та приватними підмережами.

**Ресурси:**
- **VPC** - Virtual Private Cloud з CIDR блоком
- **Public Subnets (3)** - підмережі з доступом до інтернету
- **Private Subnets (3)** - ізольовані підмережі
- **Internet Gateway** - для публічних підмереж
- **NAT Gateway (3)** - для виходу приватних підмереж в інтернет
- **Route Tables** - маршрутизація трафіку

**Виходи:**
- `vpc_id` - ID створеного VPC
- `public_subnet_ids` - список ID публічних підмереж
- `private_subnet_ids` - список ID приватних підмереж
- `nat_gateway_ids` - список ID NAT Gateway

### 3️⃣ Модуль ECR

**Призначення:** Створення Elastic Container Registry для зберігання Docker-образів.

**Ресурси:**
- **ECR Repository** - репозиторій для Docker образів
  - Сканування образів при push
  - Шифрування AES256
- **Lifecycle Policy** - автоматичне очищення старих образів
  - Зберігання останніх 30 tagged образів
  - Видалення untagged образів через 7 днів
- **Repository Policy** - політика доступу

**Виходи:**
- `repository_url` - URL репозиторію ECR
- `repository_name` - ім'я репозиторію
- `repository_arn` - ARN репозиторію

## 📦 Передумови

Перед початком роботи переконайтеся, що у вас встановлено:

1. **Terraform** >= 1.0
   ```bash
   terraform version
   ```

2. **AWS CLI** з налаштованими credentials
   ```bash
   aws configure
   ```

3. **Git** для версійного контролю
   ```bash
   git --version
   ```

## ⚙️ Налаштування

### Крок 1: Клонування репозиторію

```bash
git clone <your-repository-url>
cd goit-devops-ci-cd/lesson-5
```

### Крок 2: Створення конфігураційного файлу

Скопіюйте приклад і налаштуйте змінні:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Відредагуйте `terraform.tfvars` та змініть значення:

```hcl
# ВАЖЛИВО: Змініть на своє унікальне ім'я S3 бакета!
s3_bucket_name = "your-unique-name-terraform-state-2024"

# Решта параметрів можна залишити за замовчуванням або налаштувати
aws_region     = "us-west-2"
vpc_name       = "my-vpc"
ecr_name       = "my-app-ecr"
```

### Крок 3: Ініціалізація Terraform

```bash
terraform init
```

### Крок 4: Перегляд плану

```bash
terraform plan
```

### Крок 5: Застосування конфігурації

```bash
terraform apply
```

Введіть `yes` для підтвердження створення ресурсів.

### Крок 6: Міграція state в S3 (опціонально)

Після успішного створення S3 бакета та DynamoDB:

1. Відкрийте файл `backend.tf`
2. Розкоментуйте блок `terraform`
3. Переконайтеся, що значення `bucket` відповідає вашому S3 бакету
4. Виконайте міграцію:

```bash
terraform init -migrate-state
```

## 📤 Виведення результатів

Після успішного застосування конфігурації, ви побачите:

```bash
terraform output
```

Приклад виведення:

```
s3_bucket_name        = "terraform-state-lesson-5-bucket"
dynamodb_table_name   = "terraform-locks"
vpc_id                = "vpc-0abc123def456..."
ecr_repository_url    = "123456789.dkr.ecr.us-west-2.amazonaws.com/lesson-5-ecr"
public_subnet_ids     = ["subnet-xxx", "subnet-yyy", "subnet-zzz"]
private_subnet_ids    = ["subnet-aaa", "subnet-bbb", "subnet-ccc"]
nat_gateway_ids       = ["nat-111", "nat-222", "nat-333"]
```

## 🧪 Тестування інфраструктури

### Перевірка S3 бакета

```bash
aws s3 ls s3://your-bucket-name
```

### Перевірка DynamoDB

```bash
aws dynamodb describe-table --table-name terraform-locks
```

### Перевірка VPC

```bash
aws ec2 describe-vpcs --filters "Name=tag:Name,Values=lesson-5-vpc"
```

### Перевірка ECR

```bash
aws ecr describe-repositories --repository-names lesson-5-ecr
```

### Завантаження образу в ECR

```bash
# Автентифікація в ECR
aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin <ECR_URL>

# Tag образу
docker tag my-app:latest <ECR_URL>/lesson-5-ecr:latest

# Push образу
docker push <ECR_URL>/lesson-5-ecr:latest
```

## 🧹 Очищення ресурсів

**УВАГА:** Ця команда видалить всі створені ресурси!

```bash
terraform destroy
```

Введіть `yes` для підтвердження видалення.

## 📚 Корисні команди

```bash
# Форматування коду
terraform fmt -recursive

# Валідація конфігурації
terraform validate

# Показати поточний state
terraform show

# Показати конкретний output
terraform output vpc_id

# Оновити state без змін
terraform refresh

# Імпорт існуючого ресурсу
terraform import aws_vpc.main vpc-xxxxx
```

## 🐛 Troubleshooting

### Проблема: "Error: Error creating S3 bucket: BucketAlreadyExists"

**Рішення:** Змініть значення `s3_bucket_name` в `terraform.tfvars` на унікальне ім'я.

### Проблема: "Error: NoCredentialProviders"

**Рішення:** Налаштуйте AWS credentials:
```bash
aws configure
```

## 📖 Додаткові матеріали

- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS VPC Best Practices](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-security-best-practices.html)
- [Terraform Backend Configuration](https://www.terraform.io/docs/language/settings/backends/s3.html)
- [AWS ECR User Guide](https://docs.aws.amazon.com/AmazonECR/latest/userguide/what-is-ecr.html)

## 👨‍💻 Автор

Створено як частину навчального проєкту GoIT DevOps курсу.

## 📝 Ліцензія

Цей проєкт створений для навчальних цілей.

---

