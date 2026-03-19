from flask import Flask, Response
from prometheus_client import generate_latest, Counter, CONTENT_TYPE_LATEST

app = Flask(__name__)

# Métrica de exemplo
REQUESTS = Counter("http_requests_total", "Total HTTP Requests", ["endpoint"])

@app.route("/")
def home():
    REQUESTS.labels(endpoint="/").inc()
    return "Fintech DevSecOps Lab Running"

@app.route("/health")
def health():
    REQUESTS.labels(endpoint="/health").inc()
    return {"status": "ok"}

# Endpoint de métricas para Prometheus
@app.route("/metrics")
def metrics():
    return Response(generate_latest(), mimetype=CONTENT_TYPE_LATEST)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
