pipeline {
agent any

```
environment {
    DOCKER_IMAGE = '075237969143.dkr.ecr.us-east-1.amazonaws.com/java-application'
    ECR_REGISTRY = '075237969143.dkr.ecr.us-east-1.amazonaws.com'
    ECR_REGION = 'us-east-1'
    CLUSTER_NAME = 'jenkins-cicd-cluster-prod'

    AWS_ACCESS_KEY_ID = credentials('AWS_ACCESS_KEY_ID')
    AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
}

stages {

    stage('Clone Repository') {
        steps {
            git branch: 'main',
                credentialsId: 'java_repo_creds',
                url: 'https://github.com/sanghasevak/java-application.git'
        }
    }

    stage('Build WAR') {
        steps {
            script {
                docker.image('maven:3.9.6-eclipse-temurin-17').inside {
                    sh 'mvn clean package'
                }
            }
        }
    }

    stage('Build Docker Image') {
        steps {
            script {
                docker.build("${DOCKER_IMAGE}:${BUILD_NUMBER}")
            }
        }
    }

    stage('Push Image to ECR') {
        steps {
            sh """
                aws ecr get-login-password --region ${ECR_REGION} | \
                docker login --username AWS --password-stdin ${ECR_REGISTRY}

                docker push ${DOCKER_IMAGE}:${BUILD_NUMBER}
            """
        }
    }

    stage('Update Deployment YAML') {
        steps {
            sh """
                sed -i "s|image: .*|image: ${DOCKER_IMAGE}:${BUILD_NUMBER}|g" deployment/deployment.yaml

                cat deployment/deployment.yaml | grep image
            """
        }
    }

    stage('Commit Changes To Git') {
        steps {
            withCredentials([
                usernamePassword(
                    credentialsId: 'java_repo_creds',
                    usernameVariable: 'GIT_USERNAME',
                    passwordVariable: 'GIT_PASSWORD'
                )
            ]) {

                sh """
                    git config user.email "sanghasevak@gmail.com"
                    git config user.name "sanghasevak"

                    git add deployment/deployment.yaml

                    git commit -m "Update image tag to ${BUILD_NUMBER}" || echo "No changes"

                    git remote set-url origin https://${GIT_USERNAME}:${GIT_PASSWORD}@github.com/sanghasevak/java-application.git

                    git push origin main
                """
            }
        }
    }

    stage('Configure EKS Access') {
        steps {
            sh """
                aws eks update-kubeconfig \
                --region ${ECR_REGION} \
                --name ${CLUSTER_NAME}

                kubectl get nodes
            """
        }
    }

    stage('Deploy to EKS') {
        steps {
            sh """
                kubectl apply -f deployment/deployment.yaml

                kubectl rollout status deployment/java-app-deployment --timeout=300s
            """
        }
    }

    stage('Verify Deployment') {
        steps {
            sh """
                kubectl get deployment java-app-deployment
                kubectl get pods -l app=java
                kubectl get svc java-app-service
            """
        }
    }
}

post {

    success {
        echo 'Deployment completed successfully'
    }

    failure {
        echo 'Deployment failed'
    }
}
```

}
