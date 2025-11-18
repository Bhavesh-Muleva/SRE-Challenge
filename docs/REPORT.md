# SRE-II Challenge — Final Report
**Environment:** Kind-based Kubernetes cluster  
**Monitoring:** Prometheus + Grafana (kube-prometheus-stack)

---

## 1. Overview

This challenge simulates four realistic production failures inside a Kubernetes environment:

1. NetworkPolicy blocking DNS requests toward CoreDNS  
2. Incorrect backend service name causing DNS resolution failure  
3. Service selector mismatch causing empty endpoints  
4. Frontend OOMKilled due to insufficient memory limits  

The goal was to reproduce, diagnose, fix, and validate each issue using Kubernetes tooling and dashboards.  
All supporting evidence (diagnostics, fixes, validations) is provided under:
```bash
troubleshooting/problem-/diagnostics/
troubleshooting/problem-/fix/
troubleshooting/problem-*/validation/
```
---

## 2. Problem 1: NetworkPolicy Blocking DNS

### Symptoms
- Frontend unable to resolve backend service.
- `nslookup`, `curl`, and pod logs showed DNS errors.

### Diagnostics
Evidence files:
```bash
troubleshooting/problem-1-networkpolicy-dns/diagnostics/
01_pods_wide.txt
02_describe_frontend.txt
03_init_logs_dns_failure.txt
04_nslookup_google_before_fix.txt
05_networkpolicies_before_fix.yaml
06_describe_blocking_netpol.txt
07_coredns_logs.txt
```

Findings:
- `/etc/resolv.conf` pointed correctly to CoreDNS.
- NetworkPolicy denied all egress except ports 80/443.
- CoreDNS logs showed no DNS queries.
- Direct connectivity to port 53 would fail.

### Root Cause
NetworkPolicy was blocking DNS traffic (UDP/TCP port 53).

### Fix
```bash
troubleshooting/problem-1-networkpolicy-dns/fix/network-policy-fixed.yaml
```
### Verification
```bash
troubleshooting/problem-1-networkpolicy-dns/validation/
01_init_logs_dns_success.txt
02_networkpolicy_after.txt
03_pods_wide.txt
nslookup_after.txt
```
DNS resolution and connectivity restored.

---

## 3. Problem 2: Incorrect Backend Service Name (Service DNS Failure)

### Symptoms
- Frontend container logs indicated:
lookup backed: no such host


- DNS resolution for backend failed.

### Diagnostics
Evidence:
```bash
troubleshooting/problem-2-service-dns/diagnostics/
01_pods_wide.txt
02_describe_frontend.txt
03_init_container_logs.txt
04_nslookup_backend_before.txt
05_service_name_check.txt
06_frontend_endpoint_check.txt
```

Findings:
- Backend URL in the Deployment used `backend-svc-wrong` instead of `backend-svc`.
- Environment variables were incorrect.
- Endpoints were not used by frontend due to DNS failure.

### Root Cause
Incorrect backend service name inside the frontend Deployment manifest.

### Fix
```bash
troubleshooting/problem-2-service-dns/fix/frontend-deploy-fix.yaml
```

### Verification
```bash
troubleshooting/problem-2-service-dns/validation/01_nslookup_backend_after.txt
```

Backend resolved correctly and frontend could reach backend.

---

## 4. Problem 3: Service Selector Mismatch (Empty Endpoints)

### Symptoms
- Backend service existed but had zero endpoints.
- Frontend could resolve DNS but connection still failed.

### Diagnostics
Evidence:
```bash
troubleshooting/problem-3-service-endpoints/diagnostics/
```
(diagnostic files as provided)

Findings:
- Backend Service selector did not match backend Deployment labels.
- Because labels differed, Kubernetes created a Service with no endpoints.

Example mismatch:
Service selector: app: backend
Pod labels: app: backend-api


### Root Cause
Label mismatch between Service selector and backend pod labels.

### Fix
```bash
troubleshooting/problem-3-service-endpoints/fix/backend-svc-working.yaml
```

### Verification
```bash
troubleshooting/problem-3-service-endpoints/validation/
01_backend_service_after_fix.txt
02_backend_endpoints_after_fix.yaml
03_init_container_after_fix.txt
04_frontend_logs_after_fix.txt
05_pods_after_fix.txt
```

Service endpoints were created and traffic flowed successfully.

---

## 5. Problem 4: OOMKilled (Memory Pressure)

### Symptoms
- Frontend repeatedly entered CrashLoopBackOff.
- Pod events showed:
Last Terminated: OOMKilled

### Diagnostics
Evidence:
```bash
troubleshooting/problem-4-memory-oom/diagnostics/
01_pods_wide.txt
02_describe_frontend.txt
OOMKilled (Last Terminated).png
OOMKilled Memory Usage.png
Pod Restart Count.png
```


Findings:
- Grafana memory charts showed the container hitting its memory limit.
- Pod restarted multiple times due to OOMKilled.

### Root Cause
Insufficient memory requests/limits defined for the frontend container.

### Fix
```bash
troubleshooting/problem-4-memory-oom/fix/frontend-deploy-fix.yaml
```

### Verification
```bash
troubleshooting/problem-4-memory-oom/validation/
01_pods_after_fix.txt
02_describe_after_fix.txt
```

Pod stabilized with no further OOMKills.  
Memory usage remained within configured limits.

---

## 6. Monitoring and Grafana Analysis

Grafana dashboards helped validate failures and recovery, including:

- Pod restart count  
- Memory usage trends showing OOM events  
- DNS failure correlation  
- Pod-level and Deployment-level stability after fixes  

Example PromQL used:
```bash
sum by (pod) (kube_pod_container_status_restarts_total{pod=~"$pod"})
```


Screenshots are located in:
```bash
screenshots/
```

---

## 7. AWS/EKS/VPC Considerations

If this scenario occurred in AWS EKS inside a VPC:

### DNS
- Security groups must allow UDP/TCP 53.  
- VPC must enable:
```bash
enableDnsSupport = true
enableDnsHostnames = true
```

- CoreDNS running in private subnets requires NAT for outbound DNS.

### Service Networking
- Ensure pod-to-pod communication is allowed through SGs.  
- Validate CNI rules and routing tables.

Helpful commands:
```bash
aws ec2 describe-security-groups --group-ids <sg-id>
aws eks describe-cluster --name <cluster>
kubectl -n kube-system logs -l k8s-app=kube-dns
```
---

## 8. Recommendations and Prevention

- Add Prometheus alerts:
  - Pod restart rate
  - OOMKilled events
  - Missing service endpoints
  - DNS errors  
- Validate Kubernetes manifests in CI/CD:
  - Label/selector mismatches
  - Incorrect env variables
  - Required limits/requests  
- Add readiness/liveness probes  
- Implement HPA based on memory usage  
- Maintain runbooks for DNS and resource-related failures  

---

## 9. Final Cluster Verification

All four issues were resolved and verified:

- All pods in Running state  
- No further OOMKills  
- DNS resolution working  
- Service endpoints populated  
- Full frontend-to-backend communication restored  
- Grafana metrics stable  

Verification files:
```bash
troubleshooting/*/validation/
```