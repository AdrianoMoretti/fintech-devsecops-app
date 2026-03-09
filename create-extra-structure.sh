#!/bin/bash

echo "Criando diretórios para ConfigMaps, Secrets e scripts auxiliares..."

BASE_DIR="$HOME/fintech-devsecops-app"

# Diretórios
DIRS=("configmaps" "secrets" "scripts")

for DIR in "${DIRS[@]}"; do
  FULL_PATH="$BASE_DIR/$DIR"
  if [ ! -d "$FULL_PATH" ]; then
    mkdir -p "$FULL_PATH"
    echo "Diretório criado: $FULL_PATH"
  else
    echo "Diretório já existe: $FULL_PATH"
  fi
done

echo "Estrutura pronta. Use 'configmaps/' para ConfigMaps, 'secrets/' para Secrets dos serviços, e 'scripts/' para automações."
