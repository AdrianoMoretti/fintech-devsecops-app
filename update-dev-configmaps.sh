#!/bin/bash
# update-dev-configmaps-no-yq.sh
# Atualiza os ConfigMaps dos serviços de dev usando apenas kubectl

NAMESPACE=dev
SERVICES=("account-service" "api-gateway" "auth-service" "payment-service" "user-service")

for svc in "${SERVICES[@]}"; do
    CONFIG_FILE="./k8s/overlays/dev/$svc/configmaps/${svc}-configmap.yaml"

    if [[ ! -f "$CONFIG_FILE" ]]; then
        echo "Arquivo não encontrado para $svc: $CONFIG_FILE"
        continue
    fi

    echo "Atualizando ConfigMap do serviço: $svc"

    # Extrair as variáveis do arquivo .yaml (formato simples KEY=VALUE)
    ENV_FILE="/tmp/${svc}-envfile"
    grep -v '^----$' "$CONFIG_FILE" | grep -v '^$' > "$ENV_FILE"

    # Delete o ConfigMap antigo e recrie com as variáveis extraídas
    kubectl delete configmap ${svc}-config -n $NAMESPACE --ignore-not-found
    kubectl create configmap ${svc}-config -n $NAMESPACE --from-env-file="$ENV_FILE"

    rm -f "$ENV_FILE"
done

echo "Todos os ConfigMaps de dev foram atualizados!"
