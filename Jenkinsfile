pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = credentials('docker-hub')
        IMAGE_NAME = "adrianomoretti/fintech-devsecops-app"
        IMAGE_TAG = "latest"
        KUBECONFIG = '/var/lib/jenkins/.kube/config'
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/AdrianoMoretti/fintech-devsecops-app.git',
                    credentialsId: 'github-token'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    docker.build("${IMAGE_NAME}:${IMAGE_TAG}")
                }
            }
        }

        stage('Security Scan') {
            steps {
                script {
                    // Executa Trivy no container mas ignora falhas
                    sh "docker run --rm -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy:latest image --exit-code 0 ${IMAGE_NAME}:${IMAGE_TAG}"
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                script {
                    docker.withRegistry('https://index.docker.io/v1/', 'docker-hub') {
                        docker.image("${IMAGE_NAME}:${IMAGE_TAG}").push()
                    }
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                script {
                    sh 'kubectl apply -f k8s/deployment.yaml -n default'
                    sh 'kubectl rollout restart deployment fintech-devsecops-app -n default'
                }
            }
        }

        stage('Smoke Test') {
            steps {
                script {
                    // Testa se a aplicação respondeu corretamente
                    sh """
                    echo "Esperando 10s para o pod iniciar..."
                    sleep 10
                    RESPONSE=\$(curl -s -o /dev/null -w "%{http_code}" http://localhost:5000)
                    if [ "\$RESPONSE" != "200" ]; then
                        echo "Smoke Test falhou! Status code: \$RESPONSE"
                        exit 1
                    else
                        echo "Smoke Test OK! Status code: \$RESPONSE"
                    fi
                    """
                }
            }
        }
    }

    post {
        always {
            echo "Pipeline finalizado. Status: ${currentBuild.currentResult}"
        }
        failure {
            echo "Pipeline falhou. Verifique os logs para detalhes."
        }
    }
}
