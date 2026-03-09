#!/bin/bash

echo "Criando estrutura Kubernetes base com NodePort e env vars..."

BASE_DIR="k8s/base"

SERVICES=(
account-service
api-gateway
auth-service
card-service
fraud-detection-service
investment-service
kyc-service
loan-service
monitoring-service
notification-service
payment-service
reporting-service
transaction-service
user-service
wallet-service
)

mkdir -p $BASE_DIR

NODEPORT_BASE=30001

for SERVICE in "${SERVICES[@]}"
do
  echo "Criando estrutura para $SERVICE"

  mkdir -p $BASE_DIR/$SERVICE

cat <<EOF > $BASE_DIR/$SERVICE/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: $SERVICE
  labels:
    app: $SERVICE
spec:
  replicas: 1
  selector:
    matchLabels:
      app: $SERVICE
  template:
    metadata:
      labels:
        app: $SERVICE
    spec:
      containers:
      - name: $SERVICE
        image: docker.io/adrianomoretti/fintech-devsecops-app:$SERVICE
        imagePullPolicy: IfNotPresent
        ports:
        - containerPort: 5000
        env:
          - name: APP_NAME
            valueFrom:
              configMapKeyRef:
                name: $SERVICE-config
                key: APP_NAME
          - name: APP_ENV
            valueFrom:
              configMapKeyRef:
                name: $SERVICE-config
                key: APP_ENV
          - name: LOG_LEVEL
            valueFrom:
              configMapKeyRef:
                name: $SERVICE-config
                key: LOG_LEVEL
          - name: DB_USER
            valueFrom:
              secretKeyRef:
                name: $SERVICE-secret
                key: DB_USER
          - name: DB_PASSWORD
            valueFrom:
              secretKeyRef:
                name: $SERVICE-secret
                key: DB_PASSWORD
          - name: API_KEY
            valueFrom:
              secretKeyRef:
                name: $SERVICE-secret
                key: API_KEY
        resources:
          requests:
            memory: "128Mi"
            cpu: "250m"
          limits:
            memory: "256Mi"
            cpu: "500m"
      imagePullSecrets:
      - name: docker-hub
---
apiVersion: v1
kind: Service
metadata:
  name: $SERVICE-service
spec:
  type: NodePort
  selector:
    app: $SERVICE
  ports:
  - protocol: TCP
    port: 5000
    targetPort: 5000
    nodePort: $NODEPORT_BASE
EOF

  ((NODEPORT_BASE++))

cat <<EOF > $BASE_DIR/$SERVICE/kustomization.yaml
resources:
- deployment.yaml
- service.yaml
EOF

done

# Kustomization principal
KUSTOMIZATION="$BASE_DIR/kustomization.yaml"
echo "resources:" > $KUSTOMIZATION
for SERVICE in "${SERVICES[@]}"
do
  echo "- $SERVICE" >> $KUSTOMIZATION
done

echo "Estrutura completa criada em $BASE_DIR"
