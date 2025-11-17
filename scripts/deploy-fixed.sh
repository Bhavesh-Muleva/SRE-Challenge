#!/bin/bash
set -e

echo "=============================================="
echo "Deploying FIXED Atlan Challenge Environment"
echo "=============================================="

echo ""
echo " Applying FIXED BACKEND (correct selector)..."
kubectl apply -f ../environment/after-fix/backend/backend-deployment-fix.yaml
kubectl apply -f ../environment/after-fix/backend/backend-service-fix.yaml

echo ""
echo " Applying FIXED FRONTEND:"
echo "    - Correct BACKEND_URL"
echo "    - Increased memory limits"
echo "    - Clean workload"
kubectl apply -f ../environment/after-fix/frontend/frontend-deployment-fix.yaml
kubectl apply -f ../environment/after-fix/frontend/frontend-service-fix.yaml

echo ""
echo " Applying FIXED NetworkPolicy (DNS allowed)..."
kubectl apply -f ../environment/after-fix/networkpolicy/allow-dns.yaml

echo ""
echo "=============================================="
echo "✅ FIXED environment deployed successfully!"
echo "=============================================="
echo "Run: kubectl get pods -o wide"
