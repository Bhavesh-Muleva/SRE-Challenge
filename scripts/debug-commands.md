# 🔍 Debug Commands Reference

## Pods
```bash
kubectl get pods -o wide
kubectl describe pod <pod>
kubectl logs <pod> -c <container>

DNS
kubectl exec -it <pod> -- nslookup google.com
kubectl exec -it <pod> -- nslookup backend-svc

NetworkPolicy
kubectl get networkpolicy -o yaml

Services & Endpoints
kubectl get svc backend-svc -o wide
kubectl get ep backend-svc -o yaml

Resource Usage
kubectl top pod
kubectl top node

Curl Test
kubectl run curl-test --rm -it --image=curlimages/curl -- curl http://backend-svc.default.svc.cluster.local
```
