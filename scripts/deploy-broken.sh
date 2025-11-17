#!/bin/bash

set -e

echo "=============================================="
echo "🚨 Deploying BROKEN Atlan Challenge Environment"
echo "=============================================="

echo ""
echo "Applying BACKEND (broken selector)..."
kubectl apply -f ../environment/before-fix/backend/backend-deployment.yaml
kubectl apply -f ../environment/before-fix/backend/backend-service.yaml

echo ""
echo "Applying FRONTEND with:"
echo "    - Wrong BACKEND_URL"
echo "    - OOM-causing memory workload"
echo "    - Init container (DNS + backend checks)"
kubectl apply -f ../environment/before-fix/frontend/frontend-deployment.yaml
kubectl apply -f ../environment/before-fix/frontend/frontend-service.yaml

echo ""
echo "Applying NetworkPolicy that BLOCKS DNS..."
kubectl apply -f ../environment/before-fix/networkpolicy/deny-dns.yaml

echo ""
echo "=============================================="
echo "✅ Broken environment deployed successfully!"
echo "=============================================="
echo ""
echo "Use kubectl get pods -o wide to inspect resources."
echo "Run scripts/debug-commands.md for troubleshooting commands."
