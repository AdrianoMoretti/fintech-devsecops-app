#!/bin/bash

echo "Criando overlays: dev, staging e prod..."

OVERLAYS_DIR="k8s/overlays"
BASE_DIR="../base"  # path relativo do overlay para o base

ENVIRONMENTS=(dev staging prod)

for ENV in "${ENVIRONMENTS[@]}"
do
  OVERLAY="$OVERLAYS_DIR/$ENV"
  mkdir -p $OVERLAY

  # Cria kustomization.yaml
  cat <<EOF > $OVERLAY/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
EOF

  # Adiciona todos os serviços do base
  for SERVICE_DIR in $(ls -1 ../base)
  do
    echo "- $BASE_DIR/$SERVICE_DIR" >> $OVERLAY/kustomization.yaml
  done

  # Cria ConfigMap específico do ambiente
  cat <<EOF > $OVERLAY/configmap-$ENV.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config-$ENV
data:
  APP_ENV: "$ENV"
  LOG_LEVEL: "INFO"
EOF

  echo "Overlay $ENV criado em $OVERLAY"
done

echo "Todos os overlays foram criados!"
