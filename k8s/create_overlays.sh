#!/bin/bash
# Script para criar overlays dev, staging e prod usando Kustomize

K8S_DIR="/home/devops/fintech-devsecops-app/k8s"
OVERLAYS=("dev" "staging" "prod")

echo "🔧 Criando overlays para cada ambiente..."

for env in "${OVERLAYS[@]}"; do
    mkdir -p "$K8S_DIR/overlays/$env"
    
    cat > "$K8S_DIR/overlays/$env/kustomization.yaml" <<EOF
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - ../../base

namePrefix: ${env}-
namespace: ${env}

images:
  - name: docker.io/adrianomoretti/fintech-devsecops-app
    newTag: "${env}"

configMapGenerator:
  - name: ${env}-config
    files:
      - ../../base/configmaps.yaml

secretGenerator:
  - name: ${env}-secrets
    literals:
      - DOCKER_USER=adrianomoretti
      - DOCKER_PASS=********
    type: kubernetes.io/basic-auth
EOF

done

echo "✅ Overlays criados para dev, staging e prod."
