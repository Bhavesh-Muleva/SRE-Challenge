# SRE-II Challenge — Final Report
**Environment:** Kind-based Kubernetes cluster  
**Monitoring:** Prometheus + Grafana (kube-prometheus-stack)

---

## 1. Overview

This challenge simulates a production outage involving three independent issues:

1. NetworkPolicy blocking DNS traffic to CoreDNS  
2. Incorrect service name causing Kubernetes DNS failure  
3. Frontend pod repeatedly OOMKilled due to low memory limits  

The objective was to reproduce, diagnose, fix, and verify each issue using Kubernetes tooling and monitoring dashboards.  
All evidence files are stored under:

```bash
troubleshooting/problem-/diagnostics/
troubleshooting/problem-/fix/
troubleshooting/problem-*/validation/
```

Grafana screenshots are located under:

```bash
screenshots/
```
---

## 2. Problem 1: NetworkPolicy Blocking DNS

### Symptoms

- Frontend pod failed to resolve the backend service.
- `nslookup backend` and `curl` returned “no such host”.
- Application logs showed DNS resolution errors.

### Diagnostics

Key evidence files:
```bash
troubleshooting/problem-1-networkpolicy-dns/diagnostics/01_pods_wide.txt
troubleshooting/problem-1-networkpolicy-dns/diagnostics/04_nslookup_backend_before.txt
troubleshooting/problem-1-networkpolicy-dns/diagnostics/05_ping_backend_before.txt
troubleshooting/problem-1-networkpolicy-dns/diagnostics/07_resolvconf_before.txt
troubleshooting/problem-1-networkpolicy-dns/diagnostics/09_describe_blocking_netpol.txt
troubleshooting/problem-1-networkpolicy-dns/diagnostics/11_coredns_logs.txt
```

Findings:

- `resolv.conf` pointed correctly to CoreDNS.
- The NetworkPolicy did not allow DNS (UDP/TCP 53).
- CoreDNS logs showed no queries from the frontend.
- `nc` to port 53 failed from the pod.

### Root Cause

A restrictive NetworkPolicy blocked DNS egress for UDP/TCP port 53.

### Fix

- Added egress rules to allow DNS traffic towards CoreDNS.
- Applied updated policy:
```bash
troubleshooting/problem-1-networkpolicy-dns/fix/network-policy-fixed.yaml
troubleshooting/problem-1-networkpolicy-dns/fix/networkpolicy.patch
```

### Verification
```bash
troubleshooting/problem-1-networkpolicy-dns/validation/01_nslookup_backend_after.txt
troubleshooting/problem-1-networkpolicy-dns/validation/03_curl_backend_after.txt
troubleshooting/problem-1-networkpolicy-dns/validation/05_nc_port53_after.txt
troubleshooting/problem-1-networkpolicy-dns/validation/07_endpoints_after.txt
```

DNS resolution and connectivity were restored.

---

## 3. Problem 2: Incorrect Service Name (Service DNS Failure)

### Symptoms

- Frontend logs indicated `lookup backed: no such host`.
- Requests failed even though backend service existed.

### Diagnostics

Evidence files:
```bash
troubleshooting/problem-2-service-dns/diagnostics/01_nslookup_backend_before.txt
troubleshooting/problem-2-service-dns/diagnostics/03_nslookup_backed_before.txt
troubleshooting/problem-2-service-dns/diagnostics/04_frontend_logs_before.txt
troubleshooting/problem-2-service-dns/diagnostics/06_describe_frontend_deploy_before.txt
```

Findings:

- The application attempted to call `backed` instead of `backend`.
- Environment variables confirmed incorrect configuration.
- Backend endpoints were not being used by frontend due to the typo.

### Root Cause

Deployment manifest contained a typo in the backend URL.

### Fix

- Updated Deployment to reference correct service name.
- Saved corrected YAML:
```bash
troubleshooting/problem-2-service-dns/fix/frontend-deploy-fix.yaml
troubleshooting/problem-2-service-dns/fix/frontend-deploy.patch
```

### Verification
```bash
troubleshooting/problem-2-service-dns/validation/01_nslookup_backend_after.txt
troubleshooting/problem-2-service-dns/validation/02_curl_backend_after.txt
troubleshooting/problem-2-service-dns/validation/06_backend_endpoints_after.txt
```

Frontend successfully reached backend after correction.

---

## 4. Problem 3: MemoryPressure and OOMKilled

### Symptoms

- Frontend pod in CrashLoopBackOff.
- Pod events showed repeated `OOMKilled`.

### Diagnostics

Evidence:
```bash
screenshots/oom/
troubleshooting/problem-3-oom/diagnostics/describe_frontend_pod.txt
```

Findings:

- Memory usage spiked to the limit before each crash.
- Node occasionally reported MemoryPressure in events.
- Grafana charts confirmed repeated OOM kills.

### Root Cause

Memory requests/limits were set too low for the workload.

### Fix

- Increased memory limits and requests.
- Updated Deployment manifest under `fix/`.
- Optionally increased replicas to distribute load.

### Verification

- Frontend remained stable with no OOMKills.
- Grafana memory graph flattened post-fix.
- `kubectl get pods` showed all pods running.

---

## 5. Monitoring and Grafana Analysis

Grafana dashboards were used for:

- Pod restart count:  
sum by (pod)(kube_pod_container_status_restarts_total{pod=~"$pod"})

- Node/pod memory usage  
- Pod restarts over time  
- Correlation between OOM events and memory limit exhaustion

Screenshots are available under:
```bash
screenshots/
```
Monitoring was essential to confirm memory-related behavior and validate system recovery.

---

## 6. AWS/EKS/VPC Considerations

If similar issues occur in EKS inside a private VPC:

- Ensure node security groups allow outbound UDP/TCP 53.  
- VPC DNS settings must have `enableDnsSupport` and `enableDnsHostnames` enabled.  
- CoreDNS pods in private subnets require NAT Gateway for upstream DNS.  
- Pod-to-pod traffic relies on correct security groups and CNI rules.  
- Commands such as the following would be helpful:
```bash
aws ec2 describe-security-groups --group-ids <sg-id>
aws eks describe-cluster --name <cluster>
kubectl -n kube-system logs -l k8s-app=kube-dns
```

---

## 7. Recommendations and Preventative Measures

- Add Prometheus alerts:
  - High pod restart rate  
  - MemoryPressure  
  - DNS resolution failures  
- Improve CI/CD:
  - Validate service selectors  
  - Lint Kubernetes manifests  
- Add readiness/liveness probes  
- Use HPA to manage load-induced memory spikes  
- Maintain runbooks for DNS failures and OOM events

---

## 8. Final Cluster Verification

- All pods are in `Running` state.  
- No new CrashLoopBackOff events.  
- DNS resolution succeeds.  
- Frontend successfully communicates with backend.  
- Metrics show stable resource usage.

All verification outputs are stored under:

```bash
troubleshooting/*/validation/
```