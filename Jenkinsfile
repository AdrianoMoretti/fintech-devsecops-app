pipeline {
    agent any

    environment {
        // Credenciais criadas no Jenkins
        GIT_CREDENTIALS = 'github-token'          // Credential do GitHub
        DOCKER_CREDENTIALS = 'dockerhub-token'    // Credential do Docker Hub
        ARGOCD_TOKEN = credentials('argocd-token') // Secret Text do ArgoCD (Service Account token)

        // Endereço do ArgoCD (NodePort exposto no cluster)
        ARGOCD_SERVER = 'https://192.168.232.129:30569' // Substitua pelo NodePort ou Ingress se tiver

        // Nome da aplicação e namespaces
        APP_NAME = 'fintech-app'
        NAMESPACE_DEV = 'dev'
        NAMESPACE_STAGING = 'staging'
        NAMESPACE_PROD = 'prod'

        // Tag da imagem Docker baseada no número do build
        IMAGE_TAG = "${env.BUILD_NUMBER}"
    }

    stages {

        stage('Checkout Code') {
            steps {
                git branch: 'main', credentialsId: "${GIT_CREDENTIALS}", url: 'git@github.com:adrianomoretti/fintech-repo.git'
            }
        }

        stage('Build & Push Docker Image') {
            steps {
                script {
                    docker.withRegistry('https://index.docker.io/v1/', "${DOCKER_CREDENTIALS}") {
                        def img = docker.build("adrianomoretti/${APP_NAME}:${IMAGE_TAG}")
                        img.push()
                    }
                }
            }
        }

        stage('Deploy to Dev') {
            steps {
                script {
                    sh """
                    # Login no ArgoCD
                    argocd login ${ARGOCD_SERVER} --username jenkins-sa --password ${ARGOCD_TOKEN} --insecure

                    # Atualiza a aplicação dev e sincroniza
                    argocd app set ${APP_NAME}-dev --repo https://github.com/adrianomoretti/fintech-repo.git --path k8s/dev --dest-server https://kubernetes.default.svc --dest-namespace ${NAMESPACE_DEV}
                    argocd app sync ${APP_NAME}-dev
                    """
                }
            }
        }

        stage('Deploy to Staging') {
            when {
                branch 'main'
            }
            steps {
                script {
                    sh """
                    argocd login ${ARGOCD_SERVER} --username jenkins-sa --password ${ARGOCD_TOKEN} --insecure
                    argocd app set ${APP_NAME}-staging --repo https://github.com/adrianomoretti/fintech-repo.git --path k8s/staging --dest-server https://kubernetes.default.svc --dest-namespace ${NAMESPACE_STAGING}
                    argocd app sync ${APP_NAME}-staging
                    """
                }
            }
        }

        stage('Deploy to Prod') {
            when {
                branch 'release/*'
            }
            steps {
                script {
                    sh """
                    argocd login ${ARGOCD_SERVER} --username jenkins-sa --password ${ARGOCD_TOKEN} --insecure
                    argocd app set ${APP_NAME}-prod --repo https://github.com/adrianomoretti/fintech-repo.git --path k8s/prod --dest-server https://kubernetes.default.svc --dest-namespace ${NAMESPACE_PROD}
                    argocd app sync ${APP_NAME}-prod
                    """
                }
            }
        }
    }

    post {
        always {
            echo "Pipeline finalizada para build ${IMAGE_TAG}"
        }
    }
}
