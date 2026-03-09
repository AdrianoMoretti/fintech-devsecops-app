pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = credentials('docker-hub')
        IMAGE_REPO = "adrianomoretti/fintech-devsecops-app"
        KUBECONFIG_PATH = "/var/lib/jenkins/.kube/config"
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/AdrianoMoretti/fintech-devsecops-app.git',
                    credentialsId: 'github-token'
            }
        }

        stage('Build & Scan Microservices') {
            steps {
                script {
                    def services = [
                        "account-service","transaction-service","payment-service",
                        "notification-service","user-service","fraud-detection-service",
                        "loan-service","investment-service","reporting-service",
                        "auth-service","kyc-service","card-service","wallet-service",
                        "api-gateway","monitoring-service"
                    ]

                    for (svc in services) {
                        def imageName = "${IMAGE_REPO}/${svc}:latest"

                        echo "Building image for ${svc}"
                        docker.build(imageName, "services/${svc}")

                        echo "Scanning image ${svc} with Trivy (vulnerabilities ignored)"
                        sh """
                            docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
                            aquasec/trivy:latest image --exit-code 0 ${imageName}
                        """

                        echo "Pushing image ${svc} to Docker Hub"
                        docker.withRegistry('https://index.docker.io/v1/', 'docker-hub') {
                            docker.image(imageName).push()
                        }
                    }
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                script {
                    echo "Deploying all microservices to Kubernetes"
                    withEnv(["KUBECONFIG=${KUBECONFIG_PATH}"]) {
                        sh 'kubectl apply -f k8s/deployments.yaml -n default'
                    }
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
