#!/bin/bash

# Diretório correto
DEPLOYMENTS_DIR="/home/devops/fintech-devsecops-app/k8s"
mkdir -p $DEPLOYMENTS_DIR

# Lista de microserviços com porta base sequencial (NodePort = 30001+)
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

NODEPORT_BASE=30001
CONTAINER_PORT=5000

echo "Atualizando Deployments e Services para usar ConfigMaps, Secrets e NodePorts na pasta $DEPLOYMENTS_DIR..."

for i in "${!MICROSERVICES[@]}"; do
  svc=${MICROSERVICES[$i]}
  node_port=$((NODEPORT_BASE + i))

  # Criar Deployment atualizado
  cat <<EOL > $DEPLOYMENTS_DIR/${svc}-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ${svc}
  labels:
    app: ${svc}
spec:
  replicas: 1
  selector:
    matchLabels:
      app: ${svc}
  template:
    metadata:
      labels:
        app: ${svc}
    spec:
      containers:
      - name: ${svc}
        image: docker.io/adrianomoretti/fintech-devsecops-app:${svc}
        imagePullPolicy: IfNotPresent
        ports:
        - containerPort: ${CONTAINER_PORT}
        env:
          - name: APP_NAME
            valueFrom:
              configMapKeyRef:
                name: ${svc}-config
                key: APP_NAME
          - name: APP_ENV
            valueFrom:
              configMapKeyRef:
                name: ${svc}-config
                key: APP_ENV
          - name: LOG_LEVEL
            valueFrom:
              configMapKeyRef:
                name: ${svc}-config
                key: LOG_LEVEL
          - name: DB_USER
            valueFrom:
              secretKeyRef:
                name: ${svc}-secret
                key: DB_USER
          - name: DB_PASSWORD
            valueFrom:
              secretKeyRef:
                name: ${svc}-secret
                key: DB_PASSWORD
          - name: API_KEY
            valueFrom:
              secretKeyRef:
                name: ${svc}-secret
                key: API_KEY
        resources:
          requests:
            memory: "128Mi"
            cpu: "250m"
          limits:
            memory: "256Mi"
            cpu: "500m"
      imagePullSecrets:
      - name: dockerhub-secret
---
apiVersion: v1
kind: Service
metadata:
  name: ${svc}-service
spec:
  type: NodePort
  selector:
    app: ${svc}
  ports:
  - protocol: TCP
    port: ${CONTAINER_PORT}
    targetPort: ${CONTAINER_PORT}
    nodePort: ${node_port}
EOL

  echo "Deployment e Service atualizados para $svc → NodePort: $node_port"
done

echo "Todos os Deployments foram atualizados e salvos em $DEPLOYMENTS_DIR."
echo "Agora é só aplicar: kubectl apply -f $DEPLOYMENTS_DIR/"
