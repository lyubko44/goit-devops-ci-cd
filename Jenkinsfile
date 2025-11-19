pipeline {
    agent {
        kubernetes {
            yaml """
apiVersion: v1
kind: Pod
spec:
  serviceAccountName: jenkins
  containers:
  - name: kaniko
    image: gcr.io/kaniko-project/executor:latest
    command:
    - sleep
    args:
    - 99d
    volumeMounts:
    - name: aws-credentials
      mountPath: /root/.aws
    env:
    - name: AWS_REGION
      value: eu-central-1
    resources:
      requests:
        cpu: 500m
        memory: 1Gi
      limits:
        cpu: 1
        memory: 2Gi
  - name: git
    image: alpine/git:latest
    command:
    - sleep
    args:
    - 99d
    resources:
      requests:
        cpu: 100m
        memory: 128Mi
      limits:
        cpu: 500m
        memory: 512Mi
  - name: aws-cli
    image: amazon/aws-cli:latest
    command:
    - sleep
    args:
    - 99d
    volumeMounts:
    - name: aws-credentials
      mountPath: /root/.aws
    env:
    - name: AWS_REGION
      value: eu-central-1
  volumes:
  - name: aws-credentials
    secret:
      secretName: aws-credentials
"""
        }
    }

    environment {
        AWS_REGION = 'eu-central-1'
        ECR_REGISTRY = credentials('ecr-registry-url')
        ECR_REPOSITORY = credentials('ecr-repository-name')
        GIT_REPO_URL = credentials('git-repo-url')
        IMAGE_TAG = "${env.BUILD_NUMBER}-${env.GIT_COMMIT.take(7)}"
    }

    stages {
        stage('Checkout') {
            steps {
                container('git') {
                    script {
                        sh '''
                            git config --global user.name "Jenkins"
                            git config --global user.email "jenkins@example.com"
                        '''
                    }
                }
            }
        }

        stage('Build and Push Docker Image') {
            steps {
                container('kaniko') {
                    script {
                        def ecrUrl = "${ECR_REGISTRY}/${ECR_REPOSITORY}"
                        def imageTag = "${ecrUrl}:${IMAGE_TAG}"
                        def latestTag = "${ecrUrl}:latest"

                        // Kaniko uses AWS credentials from mounted volume automatically
                        sh """
                            /kaniko/executor \
                                --context=/workspace \
                                --dockerfile=/workspace/Dockerfile \
                                --destination=${imageTag} \
                                --destination=${latestTag} \
                                --cache=true \
                                --cache-ttl=24h \
                                --snapshot-mode=redo \
                                --compressed-caching=false
                        """
                    }
                }
            }
        }

        stage('Update Helm Chart Values') {
            steps {
                container('git') {
                    script {
                        withCredentials([usernamePassword(credentialsId: 'git-credentials', usernameVariable: 'GIT_USER', passwordVariable: 'GIT_PASS')]) {
                            // Clone the repository with Helm charts
                            sh """
                                git clone https://${GIT_USER}:${GIT_PASS}@${GIT_REPO_URL#https://} /tmp/helm-repo || \
                                (cd /tmp/helm-repo && git pull)
                                cd /tmp/helm-repo
                                
                                # Update values.yaml with new image tag
                                sed -i 's|tag:.*|tag: "${IMAGE_TAG}"|g' lesson-7/charts/django-app/values.yaml
                                sed -i 's|repository:.*|repository: "${ECR_REGISTRY}/${ECR_REPOSITORY}"|g' lesson-7/charts/django-app/values.yaml
                                
                                # Commit and push changes
                                git add lesson-7/charts/django-app/values.yaml
                                git commit -m "Update Django app image to ${IMAGE_TAG}" || true
                                git push https://${GIT_USER}:${GIT_PASS}@${GIT_REPO_URL#https://} main
                            """
                        }
                    }
                }
            }
        }
    }

    post {
        success {
            echo "Pipeline succeeded! Image ${ECR_REGISTRY}/${ECR_REPOSITORY}:${IMAGE_TAG} pushed to ECR"
            echo "Helm chart updated in repository"
        }
        failure {
            echo "Pipeline failed!"
        }
        always {
            cleanWs()
        }
    }
}

