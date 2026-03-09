#!/bin/bash

# Diretório da base criada na Etapa 2
BASE_DIR="fintech-devsecops-app/base"

# Porta inicial para NodePort
NODEPORT_START=30001

# Lista de microserviços (mesma ordem da Etapa 2)
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

# Criar pasta overlay se não existir
OVERLAY_DIR="fintech-devsecops-app/overlay/nodeport"
mkdir -p $OVERLAY_DIR

echo "Gerando Services NodePort sequenciais..."

port=$NODEPORT_START

for svc in "${MICROSERVICES[@]}"; do
  mkdir -p $OVERLAY_DIR/$svc
  cat <<EOL > $OVERLAY_DIR/$svc/service-nodeport.yaml
apiVersion: v1
kind: Service
metadata:
  name: $svc-service
spec:
  type: NodePort
  selector:
    app: $svc
  ports:
  - protocol: TCP
    port: 5000
    targetPort: 5000
    nodePort: $port
EOL
  echo "Service NodePort criado para $svc na porta $port"
  port=$((port+1))
done

echo "Todos os Services NodePort foram criados na pasta $OVERLAY_DIR."
