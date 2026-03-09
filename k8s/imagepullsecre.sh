#!/bin/bash
# Script para corrigir imagePullSecrets nos deployments

K8S_DIR="/home/devops/fintech-devsecops-app/k8s"

echo "🔧 Corrigindo imagePullSecrets para 'docker-hub' nos deployments do Kubernetes..."

# Loop por todos os arquivos YAML na pasta
for file in "$K8S_DIR"/*.yaml; do
    if grep -q "imagePullSecrets" "$file"; then
        echo "Processando $file..."
        # Substitui 'dockerhub-secret' por 'docker-hub'
        sed -i 's/dockerhub-secret/docker-hub/g' "$file"
    fi
done

echo "✅ Todos os deployments atualizados para usar 'docker-hub'."
