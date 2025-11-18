#!/bin/bash
set -e

echo "=============================================="
echo "Installing Monitoring Stack (Prometheus + Grafana)"
echo "=============================================="

# Create namespace
kubectl create namespace monitoring || true

echo ""
echo "Installing kube-prometheus-stack (using values file)..."
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

helm upgrade --install kube-prom-stack prometheus-community/kube-prometheus-stack \
  -n monitoring \
  -f ./monitoring-stack-config.yaml

echo ""
echo "=============================================="
echo "Installing Metrics Server"
echo "=============================================="

curl -LO https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

kubectl patch deployment metrics-server -n kube-system \
  --type=json \
  -p='[{"op": "add", "path": "/spec/template/spec/containers/0/args/-", "value": "--kubelet-insecure-tls"}]'

echo ""
echo "Monitoring stack installed successfully!"
