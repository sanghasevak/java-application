pipeline {
agent any

```
environment {
    DOCKER_IMAGE = '075237969143.dkr.ecr.us-east-1.amazonaws.com/java-application'
    ECR_REGION = 'us-east-1'
}

stages {

    stage('Cloning') {
        steps {
            git branch: 'main',
                credentialsId: 'java_repo_creds',
                url: 'https://github.com/sanghasevak/java-application.git'
        }
    }

    stage('Building Artifacts') {
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

    stage('Push to ECR') {
        steps {
            withCredentials([
                string(credentialsId: 'AWS_ACCESS_KEY_ID', variable: 'AWS_ACCESS_KEY_ID'),
                string(credentialsId: 'AWS_SECRET_ACCESS_KEY', variable: 'AWS_SECRET_ACCESS_KEY')
            ]) {

                sh """
                aws ecr get-login-password --region ${ECR_REGION} | \
                docker login --username AWS --password-stdin \
                075237969143.dkr.ecr.us-east-1.amazonaws.com

                docker push ${DOCKER_IMAGE}:${BUILD_NUMBER}
                """
            }
        }
    }

    stage('Update Deployment Manifest') {
        steps {
            sh """
            sed -i 's|image: .*|image: ${DOCKER_IMAGE}:${BUILD_NUMBER}|g' deployment/deployment.yaml
            """
        }
    }

    stage('Commit to Deploy') {
        steps {
            withCredentials([
                usernamePassword(
                    credentialsId: 'java_repo_creds',
                    usernameVariable: 'GIT_USERNAME',
                    passwordVariable: 'GIT_PASSWORD'
                )
            ]) {

                sh """
                git config user.email "cloudtech.devops001@gmail.com"
                git config user.name "CloudDevops001"

                git add deployment/deployment.yaml

                git commit -m "Update image tag to ${BUILD_NUMBER}" || true

                git remote set-url origin https://${GIT_USERNAME}:${GIT_PASSWORD}@github.com/sanghasevak/java-application.git

                git push origin main
                """
            }
        }
    }
}

post {
    success {
        echo 'Build completed successfully'
    }

    failure {
        echo 'Build failed'
    }
}
```

}

