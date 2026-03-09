#!/bin/bash

# Diretório raiz do projeto
PROJECT_DIR="fintech-devsecops-app"

# Lista de microserviços
MICROSERVICES=(
  "account-service"
  "transaction-service"
  "payment-service"
  "notification-service"
  "user-service"
  "fraud-detection-service"
  "loan-service"
  "investment-service"
  "reporting-service"
  "auth-service"
  "kyc-service"
  "card-service"
  "wallet-service"
  "api-gateway"
  "monitoring-service"
)

# Função para criar Deployment base
create_deployment() {
  local svc=$1
  cat <<EOL > $PROJECT_DIR/base/$svc/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: $svc
  labels:
    app: $svc
spec:
  replicas: 1
  selector:
    matchLabels:
      app: $svc
  template:
    metadata:
      labels:
        app: $svc
    spec:
      containers:
      - name: $svc
        image: docker.io/adrianomoretti/fintech-devsecops-app:$svc
        imagePullPolicy: IfNotPresent
        ports:
        - containerPort: 5000
        resources:
          requests:
            memory: "128Mi"
            cpu: "250m"
          limits:
            memory: "256Mi"
            cpu: "500m"
      imagePullSecrets:
      - name: dockerhub-secret
EOL
}

# Função para criar Service base
create_service() {
  local svc=$1
  cat <<EOL > $PROJECT_DIR/base/$svc/service.yaml
apiVersion: v1
kind: Service
metadata:
  name: $svc-service
spec:
  type: ClusterIP
  selector:
    app: $svc
  ports:
  - protocol: TCP
    port: 5000
    targetPort: 5000
EOL
}

echo "Populando base com Deployments e Services (imagem tag = nome do serviço)"

for svc in "${MICROSERVICES[@]}"; do
  mkdir -p $PROJECT_DIR/base/$svc
  create_deployment $svc
  create_service $svc
done

echo "Base populada com sucesso! Verifique $PROJECT_DIR/base/"
