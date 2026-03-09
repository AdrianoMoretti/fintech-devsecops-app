#!/bin/bash
# create-nodeport-services.sh
# Gera service.yaml como NodePort para todos os serviços em k8s/base

BASE_DIR="./k8s/base"
START_NODEPORT=30001  # Porta inicial para NodePort

# Verifica se a pasta base existe
if [ ! -d "$BASE_DIR" ]; then
    echo "Diretório $BASE_DIR não encontrado!"
    exit 1
fi

# Itera sobre cada serviço
for SERVICE_DIR in "$BASE_DIR"/*; do
    if [ -d "$SERVICE_DIR" ]; then
        SERVICE_NAME=$(basename "$SERVICE_DIR")
        SERVICE_FILE="$SERVICE_DIR/service.yaml"

        # Define nodePort atual e incrementa para o próximo
        NODEPORT=$START_NODEPORT
        START_NODEPORT=$((START_NODEPORT + 1))

        # Gera o service.yaml como NodePort
        cat > "$SERVICE_FILE" <<EOF
apiVersion: v1
kind: Service
metadata:
  name: ${SERVICE_NAME}-service
spec:
  type: NodePort
  selector:
    app: ${SERVICE_NAME}
  ports:
    - protocol: TCP
      port: 5000
      targetPort: 5000
      nodePort: ${NODEPORT}
EOF

        echo "NodePort service criado: $SERVICE_FILE (NodePort: $NODEPORT)"
    fi
done

echo "Todos os NodePort services foram gerados!"
