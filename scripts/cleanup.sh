#!/bin/bash
set -e

echo "Cleaning up ALL resources..."

kubectl delete -f ../environment/before-fix/backend --ignore-not-found
kubectl delete -f ../environment/before-fix/frontend --ignore-not-found
kubectl delete -f ../environment/before-fix/networkpolicy --ignore-not-found

kubectl delete -f ../environment/after-fix/backend --ignore-not-found
kubectl delete -f ../environment/after-fix/frontend --ignore-not-found
kubectl delete -f ../environment/after-fix/networkpolicy --ignore-not-found

echo "Deleting monitoring stack..."
helm uninstall kube-prom-stack -n monitoring || true
kubectl delete namespace monitoring --ignore-not-found

echo "Deleting metrics-server..."
helm uninstall metrics-server -n kube-system || true

echo "Cleanup complete!"
