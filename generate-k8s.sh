#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="/home/devops/fintech-devsecops-app/k8s"
YAML_FILE="${ROOT_DIR}/deployments.yaml"
PORT=5000
IMAGE_REPO="docker.io/adrianomoretti/fintech-devsecops-app"

MICROSERVICES=(
  account-service
  transaction-service
  payment-service
  notification-service
  user-service
  fraud-detection-service
  loan-service
  investment-service
  reporting-service
  auth-service
  kyc-service
  card-service
  wallet-service
  api-gateway
  monitoring-service
)

mkdir -p "${ROOT_DIR}"
: > "${YAML_FILE}"

for service in "${MICROSERVICES[@]}"; do
cat <<EOF >> "${YAML_FILE}"
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ${service}
  labels:
    app: ${service}
spec:
  replicas: 1
  selector:
    matchLabels:
      app: ${service}
  template:
    metadata:
      labels:
        app: ${service}
    spec:
      containers:
      - name: ${service}
        image: ${IMAGE_REPO}/${service}:latest
        imagePullPolicy: IfNotPresent
        ports:
        - containerPort: ${PORT}
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
  name: ${service}-service
spec:
  type: ClusterIP
  selector:
    app: ${service}
  ports:
  - protocol: TCP
    port: ${PORT}
    targetPort: ${PORT}
---
EOF
done

echo "✔ Arquivo deployments.yaml criado em: ${YAML_FILE}"
