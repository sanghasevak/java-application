stage('Commit to Deploy') {
    steps {
        script {
            sh """
                sed -i "s|075237969143.dkr.ecr.us-east-1.amazonaws.com/java-application:[0-9]*|${DOCKER_IMAGE}:${BUILD_NUMBER}|g" deployment/deployment.yaml
                export DOCKER_IMAGE=${DOCKER_IMAGE}
                export BUILD_NUMBER=${BUILD_NUMBER}
                envsubst < deployment/deployment.yaml > deployment/deployment.yaml.new
                mv deployment/deployment.yaml.new deployment/deployment.yaml
            """

            withCredentials([usernamePassword(credentialsId: 'java_repo_creds', passwordVariable: 'GIT_PASSWORD', usernameVariable: 'GIT_USERNAME')]) {
                sh '''
                    git config user.email "sanghasevak03@gmail.com"
                    git config user.name "sanghasevak"
                    git add deployment/deployment.yaml
                    git commit -m "Update image tag to ${BUILD_NUMBER}" || echo "No changes to commit"
                    git remote set-url origin https://$GIT_USERNAME:$GIT_PASSWORD@github.com/sanghasevak/java-application.git
                    git push origin main
                '''
            }
        }
    }
}
