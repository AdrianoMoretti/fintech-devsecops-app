#!/bin/bash

# Variáveis gerais
REPO="https://github.com/adrianomoretti/fintech-devsecops-app.git"
SERVER="https://kubernetes.default.svc"
PROJECT="default"
INSECURE="--insecure"

# Lista de ambientes
ENVS=("dev" "staging" "prod")

for ENV in "${ENVS[@]}"; do
  APP_NAME="core-services-${ENV}"  # um único app por ambiente
  PATH_APP="k8s/overlays/${ENV}"

  echo "-----------------------------"
  echo "Criando ou atualizando app: $APP_NAME"
  echo "-----------------------------"

  # Verifica se o app já existe
  EXISTS=$(kubectl get app -n argocd "$APP_NAME" --ignore-not-found)

  if [ -z "$EXISTS" ]; then
    echo "App $APP_NAME não existe. Criando..."
    argocd app create "$APP_NAME" \
      --repo "$REPO" \
      --path "$PATH_APP" \
      --dest-server "$SERVER" \
      --dest-namespace "$ENV" \
      --project "$PROJECT" \
      --sync-policy automated \
      $INSECURE
  else
    echo "App $APP_NAME já existe, pulando criação..."
  fi

  # Força o sync do app
  echo "Sincronizando app $APP_NAME..."
  argocd app sync "$APP_NAME" $INSECURE
  echo
done

echo "Todos os apps processados."
