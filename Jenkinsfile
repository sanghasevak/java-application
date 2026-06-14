pipeline {
    agent any

    environment {
        DOCKER_IMAGE = '075237969143.dkr.ecr.us-east-1.amazonaws.com/java-application'
        ECR_REGION = 'us-east-1'

        AWS_ACCESS_KEY_ID = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
    }

    stages {

        stage('Cloning') {
            steps {
                git branch: 'main',
                    credentialsId: 'java_repo_creds',
                    url: 'https://github.com/faizankitty4554-oss/java-application.git'
            }
        }

        stage('Building Artifacts') {
            steps {
                script {
                    docker.image('maven:3.6.3-jdk-8').inside {
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
                sh """
                    aws configure set aws_access_key_id ${AWS_ACCESS_KEY_ID}
                    aws configure set aws_secret_access_key ${AWS_SECRET_ACCESS_KEY}
                    aws configure set region ${ECR_REGION}

                    aws ecr get-login-password --region ${ECR_REGION} | docker login --username AWS --password-stdin 075237969143.dkr.ecr.us-east-1.amazonaws.com

                    docker push ${DOCKER_IMAGE}:${BUILD_NUMBER}
                """
            }
        }

        stage('Commit to Deploy') {
            steps {
                script {

                    sh """
                        sed -i 's|075237969143.dkr.ecr.us-east-1.amazonaws.com/java-application:[0-9]*|${DOCKER_IMAGE}:${BUILD_NUMBER}|g' deployment/deployment.yaml
                    """

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
                            git commit -m "Update image tag to ${BUILD_NUMBER}" || echo "No changes to commit"

                            git remote set-url origin https://${GIT_USERNAME}:${GIT_PASSWORD}@github.com/sanghasevak/java-application.git

                            git push origin main
                        """
                    }
                }
            }
        }
    }
}
