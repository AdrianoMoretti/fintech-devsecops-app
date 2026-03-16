#!/bin/bash
# create-core-5apps-argocd.sh - Cria apps no ArgoCD para dev, staging e prod
# Autor: Você
# Data: 2026-03-14

set -e

# Configurações
REPO="https://github.com/adrianomoretti/fintech-devsecops-app.git"
SERVICES=("account-service" "payment-service" "user-service" "api-gateway" "auth-service")
ENVS=("dev" "staging" "prod")
PROJECT="default"

# Função para criar ou sincronizar app
create_or_sync_app() {
    local service=$1
    local env=$2
    local path="k8s/overlays/$env/$service"
    local app_name="${service}-${env}"

    echo "--------------------------------"
    echo "Processando $app_name"
    echo "Path: $path"
    echo "--------------------------------"

    # Checa se já existe
    if argocd app get "$app_name" &>/dev/null; then
        echo "App já existe. Sincronizando..."
        argocd app sync "$app_name"
    else
        echo "Criando aplicação..."
        argocd app create "$app_name" \
            --repo "$REPO" \
            --path "$path" \
            --dest-server https://kubernetes.default.svc \
            --dest-namespace "$env" \
            --project "$PROJECT" \
            --sync-policy automated
    fi
    echo
}

# Loop em cada serviço e ambiente
for env in "${ENVS[@]}"; do
    for service in "${SERVICES[@]}"; do
        create_or_sync_app "$service" "$env"
    done
done

echo "--------------------------------"
echo "Todos os apps processados"
echo "--------------------------------"
