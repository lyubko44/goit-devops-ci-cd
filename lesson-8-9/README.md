# Lesson 8-9: Terraform EKS + ECR + Helm + Jenkins + Argo CD (Django)

Цей каталог створює повний CI/CD стек на AWS: VPC, ECR, EKS, Jenkins та Argo CD. Helm-чарт розгортає Django-застосунок з HPA, Service типу LoadBalancer, ConfigMap, а також (опціонально) Ingress + TLS.

## Архітектура CI/CD

1. **Jenkins** - автоматизує збірку Docker-образів та публікацію в ECR
2. **Argo CD** - автоматично синхронізує зміни з Git репозиторію в Kubernetes кластер
3. **Helm** - керує розгортанням застосунків через чарти
4. **Terraform** - інфраструктура як код для всіх компонентів

## Попередні вимоги
- Встановлені: Terraform, AWS CLI, kubectl, Helm.
- AWS облікові дані (AWS_PROFILE або змінні середовища).

## 1) Підготовка бекенду для Terraform state (S3 + DynamoDB)
Backend описано у `backend.tf`. Замініть значення при потребі:
- bucket: `goit-devops-tf-state`
- key: `lesson-8-9/terraform.tfstate`
- region: `eu-central-1`
- dynamodb_table: `goit-devops-tf-locks`

Якщо бакет/таблиця ще не існують, їх можна створити одноразово локальним стейтом через модуль `modules/s3-backend` (або створити вручну).

## 2) Ініціалізація і створення інфраструктури
```bash
cd lesson-8-9
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
- Jenkins (`jenkins_url` та `jenkins_admin_password` в outputs)
- Argo CD (`argocd_url` та `argocd_admin_password` в outputs)

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

## 7) Jenkins CI/CD Pipeline

### Доступ до Jenkins

Після розгортання отримайте URL та пароль адміністратора:
```bash
JENKINS_URL=$(terraform output -raw jenkins_url)
JENKINS_PASSWORD=$(terraform output -raw jenkins_admin_password)

echo "Jenkins URL: $JENKINS_URL"
echo "Admin Password: $JENKINS_PASSWORD"
```

### Налаштування Jenkins

1. Відкрийте Jenkins URL у браузері
2. Увійдіть з логіном `admin` та паролем з `terraform output`
3. Встановіть рекомендовані плагіни
4. Створіть облікові дані:
   - **ECR Registry URL**: `terraform output -raw ecr_repository_url | cut -d/ -f1`
   - **ECR Repository Name**: назва репозиторію з ECR
   - **Git Repository URL**: URL вашого Git репозиторію з Helm чартами
   - **Git Credentials**: облікові дані для доступу до Git

5. Створіть Secret для AWS credentials в Kubernetes:
```bash
kubectl create secret generic aws-credentials \
  --from-file=credentials=$HOME/.aws/credentials \
  --from-file=config=$HOME/.aws/config \
  -n jenkins
```

6. Створіть ServiceAccount для Jenkins з правами на ECR:
```bash
# Створіть IAM роль та політику для Jenkins (опціонально, якщо використовуєте IRSA)
```

7. Створіть Pipeline Job:
   - Тип: Pipeline
   - Визначення: Pipeline script from SCM
   - SCM: Git
   - Repository URL: URL вашого репозиторію з Jenkinsfile
   - Script Path: Jenkinsfile

### Jenkinsfile

Jenkinsfile автоматично:
1. Збирає Docker-образ через Kaniko
2. Публікує образ в ECR з тегом `${BUILD_NUMBER}-${GIT_COMMIT}`
3. Оновлює `values.yaml` в Git репозиторії з новим тегом
4. Пушить зміни в main гілку

## 8) Argo CD GitOps

### Доступ до Argo CD

Після розгортання отримайте URL та пароль адміністратора:
```bash
ARGOCD_URL=$(terraform output -raw argocd_url)
ARGOCD_PASSWORD=$(terraform output -raw argocd_admin_password)

echo "Argo CD URL: $ARGOCD_URL"
echo "Admin Password: $ARGOCD_PASSWORD"
```

### Налаштування Argo CD Application

1. Відкрийте Argo CD URL у браузері
2. Увійдіть з логіном `admin` та паролем з `terraform output`
3. Додайте Git репозиторій:
   - Settings → Repositories → Connect Repo
   - Вкажіть URL вашого репозиторію з Helm чартами
   - Додайте облікові дані якщо потрібно

4. Створіть Application:
   - New App
   - Application Name: `django-app`
   - Project Name: `default`
   - Sync Policy: Automatic (Auto-Create Namespace, Auto-Prune, Auto-Sync)
   - Repository URL: ваш Git репозиторій
   - Path: `lesson-8-9/charts/django-app`
   - Cluster URL: `https://kubernetes.default.svc`
   - Namespace: `default`

Або використайте Helm chart з модуля:
```bash
cd lesson-8-9/modules/argo_cd/charts
helm upgrade --install argocd-apps . \
  --set applications[0].source.repoURL=<YOUR_GIT_REPO_URL> \
  --set applications[0].source.path=charts/django-app \
  --set applications[0].destination.namespace=default \
  --namespace argocd
```

### Автоматична синхронізація

Argo CD автоматично відстежує зміни в Git репозиторії та синхронізує їх у кластер. Коли Jenkins оновлює `values.yaml` з новим тегом образу, Argo CD виявить зміни та оновить Deployment в Kubernetes.

## Структура модулів

### Модуль Jenkins (`modules/jenkins/`)
- `jenkins.tf` - Helm release для Jenkins
- `providers.tf` - Kubernetes та Helm провайдери
- `variables.tf` - Змінні модуля
- `values.yaml` - Конфігурація Jenkins з Kaniko та Git агентами
- `outputs.tf` - URL та пароль адміністратора

### Модуль Argo CD (`modules/argo_cd/`)
- `argo_cd.tf` - Helm release для Argo CD
- `providers.tf` - Kubernetes та Helm провайдери
- `variables.tf` - Змінні модуля
- `values.yaml` - Конфігурація Argo CD
- `outputs.tf` - URL та пароль адміністратора
- `charts/` - Helm chart для керування Argo CD Applications та Repositories
  - `Chart.yaml` - Метадані чарта
  - `values.yaml` - Список applications та repositories
  - `templates/application.yaml` - Шаблон для Argo CD Application
  - `templates/repository.yaml` - Шаблон для Argo CD Repository Secret

## Повний CI/CD процес

1. **Розробник** пушить код у Git репозиторій
2. **Jenkins** виявляє зміни та запускає pipeline:
   - Збирає Docker-образ через Kaniko
   - Публікує образ в ECR з унікальним тегом
   - Оновлює `values.yaml` в Git з новим тегом
3. **Argo CD** виявляє зміни в Git:
   - Отримує новий тег образу з `values.yaml`
   - Оновлює Deployment в Kubernetes
   - Синхронізує стан кластера з Git

## Troubleshooting

### Jenkins не може підключитися до ECR
Перевірте, що ServiceAccount має правильні AWS credentials:
```bash
kubectl get secret aws-credentials -n jenkins
```

### Argo CD не синхронізує зміни
Перевірте статус Application:
```bash
kubectl get applications -n argocd
argocd app get django-app
```

### Kaniko не може зібрати образ
Перевірте логи Jenkins pod:
```bash
kubectl logs -n jenkins -l app.kubernetes.io/name=jenkins
```


