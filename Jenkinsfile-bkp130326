pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = 'docker-hub'
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

                        def imageTag = "${IMAGE_REPO}:${svc}"

                        echo "Building ${svc}"

                        docker.build(imageTag, "services/${svc}")

                        echo "Scanning ${svc} with Trivy"

                        sh """
                        docker run --rm \
                        -v /var/run/docker.sock:/var/run/docker.sock \
                        aquasec/trivy:latest image --exit-code 0 ${imageTag}
                        """

                        echo "Pushing ${svc} image"

                        docker.withRegistry('https://index.docker.io/v1/', DOCKERHUB_CREDENTIALS) {
                            docker.image(imageTag).push()
                        }
                    }
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                script {

                    echo "Deploying to Kubernetes"

                    withEnv(["KUBECONFIG=${KUBECONFIG_PATH}"]) {

                        sh """
                        kubectl apply -f k8s/deployments.yaml
                        """

                    }
                }
            }
        }
    }

    post {
        always {
            echo "Pipeline finalizado: ${currentBuild.currentResult}"
        }

        failure {
            echo "Pipeline falhou. Verifique os logs."
        }
    }
}
