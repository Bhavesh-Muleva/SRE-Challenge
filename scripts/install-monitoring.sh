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

helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
helm repo update

helm upgrade --install metrics-server metrics-server/metrics-server \
  -n kube-system \
  -f ./metrics-server-values.yaml

echo ""
echo "Monitoring stack installed successfully!"
