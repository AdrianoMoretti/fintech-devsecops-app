#!/bin/bash
# create-kustomizations.sh
# Script para gerar kustomization.yaml no base e nas overlays (dev, staging, prod)

set -e

BASE_DIR="./k8s/base"
OVERLAYS_DIR="./k8s/overlays"
SERVICES=(
  "account-service" "api-gateway" "auth-service" "card-service"
  "fraud-detection-service" "investment-service" "kyc-service" "loan-service"
  "monitoring-service" "notification-service" "payment-service"
  "reporting-service" "transaction-service" "user-service" "wallet-service"
)

echo "Gerando kustomization.yaml para cada serviço..."
for svc in "${SERVICES[@]}"; do
  SERVICE_DIR="$BASE_DIR/$svc"
  cat > "$SERVICE_DIR/kustomization.yaml" <<EOF
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - deployment.yaml
  - service.yaml
EOF
  echo "Kustomization gerado para $svc"
done

echo "Gerando kustomization.yaml do base..."
cat > "$BASE_DIR/kustomization.yaml" <<EOF
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
EOF

for svc in "${SERVICES[@]}"; do
  echo "  - $svc" >> "$BASE_DIR/kustomization.yaml"
done

echo "Gerando kustomization.yaml para as overlays..."
for env in dev staging prod; do
  OVERLAY_PATH="$OVERLAYS_DIR/$env"
  CONFIGMAP_FILE="configmap-$env.yaml"
  cat > "$OVERLAY_PATH/kustomization.yaml" <<EOF
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - ../../base
configMapGenerator:
  - name: ${env}-config
    files:
      - $CONFIGMAP_FILE
EOF
  echo "Overlay $env configurada"
done

echo "Todos os kustomization.yaml foram gerados com sucesso!"
