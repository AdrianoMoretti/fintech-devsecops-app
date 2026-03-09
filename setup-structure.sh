#!/bin/bash

# Nome do projeto
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

# Criar diretório raiz
mkdir -p $PROJECT_DIR
cd $PROJECT_DIR || exit

echo "Criando estrutura de diretórios..."

# Base: um diretório para cada microserviço
mkdir -p base
for svc in "${MICROSERVICES[@]}"; do
  mkdir -p base/$svc
  touch base/$svc/deployment.yaml
  touch base/$svc/service.yaml
  cat <<EOL > base/$svc/kustomization.yaml
resources:
- deployment.yaml
- service.yaml
EOL
done

# Overlays para dev/staging/prod
mkdir -p overlays/dev
mkdir -p overlays/staging
mkdir -p overlays/prod

# Criar arquivos kustomization vazios nos overlays
for env in dev staging prod; do
  cat <<EOL > overlays/$env/kustomization.yaml
resources:
EOL
done

# Criar diretório para CI/CD
mkdir -p ci-cd
touch ci-cd/pipeline.yaml

echo "Estrutura de diretórios criada com sucesso!"
