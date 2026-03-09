#!/bin/bash
# create-kustomizations-full.sh
# Script para gerar kustomization.yaml para cada serviço e overlays no formato completo

set -e

BASE_DIR="./k8s/base"
OVERLAYS_DIR="./k8s/overlays"
CONFIGMAP_DIR="./configmaps"
SERVICES=(
  "account-service" "api-gateway" "auth-service" "card-service"
  "fraud-detection-service" "investment-service" "kyc-service" "loan-service"
  "monitoring-service" "notification-service" "payment-service"
  "reporting-service" "transaction-service" "user-service" "wallet-service"
)

# 1️⃣ Gera kustomization.yaml para cada serviço
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

# 2️⃣ Gera kustomization.yaml do base
echo "Gerando kustomization.yaml do base..."
cat > "$BASE_DIR/kustomization.yaml" <<EOF
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
EOF

for svc in "${SERVICES[@]}"; do
  echo "  - $svc" >> "$BASE_DIR/kustomization.yaml"
done

# 3️⃣ Gera kustomization.yaml para as overlays (dev, staging, prod)
echo "Gerando kustomization.yaml para as overlays..."

for env in dev staging prod; do
  OVERLAY_PATH="$OVERLAYS_DIR/$env"
  CONFIGMAP_FILES=""
  for svc in "${SERVICES[@]}"; do
    CONFIGMAP_FILES="$CONFIGMAP_FILES\n      - $CONFIGMAP_DIR/${svc}-configmap.yaml"
  done

  cat > "$OVERLAY_PATH/kustomization.yaml" <<EOF
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

# referência à base de deployments
resources:
  - ../../base

# adiciona ConfigMaps específicos do $env
configMapGenerator:$CONFIGMAP_FILES

# usa secrets já criados no cluster
secretGenerator:
  - name: docker-hub
    behavior: merge
  - name: github-token
    behavior: merge
# imagens (opcional, se você quiser sobrescrever tags específicas)
images:
  - name: docker.io/adrianomoretti/fintech-devsecops-app
    newTag: latest

generatorOptions:
  disableNameSuffixHash: true
EOF

  echo "Overlay $env configurada"
done

echo "Todos os kustomization.yaml foram gerados no formato completo!"
