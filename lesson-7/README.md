# Lesson 7: Terraform EKS + ECR + Helm (Django)

Цей каталог створює інфраструктуру AWS: VPC, ECR, EKS. Helm-чарт розгортає Django-застосунок з HPA, Service типу LoadBalancer, ConfigMap, а також (опціонально) Ingress + TLS.

## Попередні вимоги
- Встановлені: Terraform, AWS CLI, kubectl, Helm.
- AWS облікові дані (AWS_PROFILE або змінні середовища).

## 1) Підготовка бекенду для Terraform state (S3 + DynamoDB)
Backend описано у `backend.tf`. Замініть значення при потребі:
- bucket: `goit-devops-tf-state`
- key: `lesson-7/terraform.tfstate`
- region: `eu-central-1`
- dynamodb_table: `goit-devops-tf-locks`

Якщо бакет/таблиця ще не існують, їх можна створити одноразово локальним стейтом через модуль `modules/s3-backend` (або створити вручну).

## 2) Ініціалізація і створення інфраструктури
```bash
cd lesson-7
terraform init
terraform plan
terraform apply -auto-approve
```

### Використати існуючий VPC
За замовчуванням `create_vpc=false` і модулі очікують, що передасте існуючі ідентифікатори:
```bash
terraform apply \
  -var='existing_vpc_id=vpc-xxxxxxxx' \
  -var='existing_private_subnet_ids=["subnet-aaaaaaa","subnet-bbbbbbb","subnet-ccccccc"]' \
  -auto-approve
```
Якщо бажаєте створити новий VPC:
```bash
terraform apply -var='create_vpc=true' -auto-approve
```

Після застосування отримаєте:
- VPC і підмережі
- ECR репозиторій (`ecr_repository_url` в outputs)
- EKS кластер

Оновіть kubeconfig для kubectl:
```bash
aws eks update-kubeconfig --name $(terraform output -raw eks_cluster_name) --region <your-region>
```

Перевірте доступ:
```bash
kubectl get nodes
```

## 3) Збирання та пуш Docker-образу у ECR
Отримайте URL ECR:
```bash
ECR_URL=$(terraform output -raw ecr_repository_url)
echo $ECR_URL
```

Авторизуйтесь у ECR:
```bash
aws ecr get-login-password --region <your-region> \
  | docker login --username AWS --password-stdin "$(echo $ECR_URL | cut -d/ -f1)"
```

Зберіть та запуште образ Django (замініть шлях до Dockerfile/контексту на ваш):
```bash
docker build -t django-app:latest <path-to-your-django-project>
docker tag django-app:latest $ECR_URL:latest
docker push $ECR_URL:latest
```

## 4) Розгортання Helm-чарта
Перейдіть у каталог чарта та встановіть значення образу в `charts/django-app/values.yaml`:
```yaml
image:
  repository: "<ECR_REPOSITORY_URL>"
  tag: "latest"
```

Інсталюйте:
```bash
helm upgrade --install django charts/django-app
```

Перевірте:
```bash
kubectl get pods
kubectl get svc
```

Сервіс типу LoadBalancer надасть зовнішню адресу:
```bash
kubectl get svc -o wide
```

## 5) HPA
HPA створюється автоматично (autoscaling.enabled=true). Потрібен встановлений `metrics-server` (в EKS зазвичай ставиться окремо):
```bash
kubectl top nodes
kubectl top pods
```

## 6) (Опційно) Ingress + TLS
Увімкніть у `values.yaml`:
```yaml
ingress:
  enabled: true
  className: nginx
  host: yourdomain.com
  path: /
  pathType: Prefix
  tls: true
  annotations:
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
```
Потрібні: встановлений ingress-controller (наприклад, nginx) і cert-manager.

## Змінні середовища (ConfigMap)
Редагуйте секцію `env` у `values.yaml`. Deployment підключає її через `envFrom`.


