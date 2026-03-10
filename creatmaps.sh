mkdir -p ~/fintech-devsecops-app/configmaps

services=(
account-service
api-gateway
auth-service
card-service
fraud-detection-service
investment-service
kyc-service
loan-service
monitoring-service
notification-service
payment-service
reporting-service
transaction-service
user-service
wallet-service
)

for svc in "${services[@]}"; do
cat <<EOF > ~/fintech-devsecops-app/configmaps/${svc}-configmap.yaml
APP_NAME=${svc}
APP_ENV=dev
LOG_LEVEL=info
EOF
done
