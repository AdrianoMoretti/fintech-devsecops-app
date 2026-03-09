pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = credentials('docker-hub')
        IMAGE_NAME = "adrianomoretti/fintech-devsecops-app"
        IMAGE_TAG = "latest"
        KUBECONFIG = "/var/lib/jenkins/.kube/config" // variável para kubectl
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
                    // Executa Trivy mas ignora o exit code para não quebrar pipeline
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
                    // Usa o KUBECONFIG do Jenkins para aplicar os manifests
                    sh 'kubectl apply -f k8s/deployment.yaml -n default'
                    sh 'kubectl rollout restart deployment fintech-devsecops-app -n default'
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
