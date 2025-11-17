#!/bin/bash

echo "Testing DNS..."
kubectl run dns-test --rm -it --image=nicolaka/netshoot --restart=Never -- nslookup google.com

echo ""
echo "Testing backend service..."
kubectl run dns-test2 --rm -it --image=nicolaka/netshoot --restart=Never -- nslookup backend-svc

echo ""
echo "Curl backend from inside cluster..."
kubectl run curl-test --rm -it --image=curlimages/curl --restart=Never -- \
  curl http://backend-svc.default.svc.cluster.local
