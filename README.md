# Challenge (Submission)

Author: Bhavesh Muleva

This repository contains a reproducible SRE challenge environment with four deliberate Kubernetes failures. It includes diagnostics, fixes, validation artifacts, monitoring setup, and documentation.

---

## Status

- Broken environment recreated  
- All four problems diagnosed and fixed  
- Validation artifacts included  
- Grafana dashboards and exported JSON included  
- Report, RCA, Improvements, Monitoring documentation included  

---

## Directory Overview

- environment/before-fix/ — manifests creating the broken environment  
- environment/after-fix/ — manifests containing fixes  
- troubleshooting/ — diagnostics, fixes, validation (per problem)  
- scripts/  
  - deploy-broken.sh  
  - deploy-fixed.sh  
  - install-monitoring.sh  
  - cleanup.sh  
  - test-connectivity.sh  
  - debug-commands.md  
  - grafana-dashboard.json  
- docs/  
  - REPORT.md  
  - RCA.md  
  - IMPROVEMENTS.md  
  - GRAFANA.md  
- screenshots/grafana/ — Grafana screenshots used as evidence  

---

## Prerequisites

- kubectl installed and configured  
- helm v3 installed  
- Bash or POSIX-compliant shell  
- (Optional) kind for local testing  

### Create a kind cluster (optional)

```bash
cd cluster
./create-cluster.sh
```

---

# How to Reproduce

## 1. Deploy the broken environment

```bash
cd scripts
./deploy-broken.sh
```

Check pod status:

```bash
kubectl get pods -o wide
```

---

## 2. (Optional) Install monitoring

Run:

```bash
./install-monitoring.sh
```

Port-forward Grafana:

```bash
kubectl port-forward -n monitoring svc/kube-prom-stack-grafana 3000:80
```

Visit:

```
http://localhost:3000
```

Username: admin  
Password: from Grafana secret

---

## 3. Run diagnostics

All commands used are listed in:

```
scripts/debug-commands.md
```

Diagnostic outputs are stored in:

```
troubleshooting/problem-*/diagnostics/
```

---

## 4. Apply fixes

```bash
./deploy-fixed.sh
```

Fixes are taken from:

```
environment/after-fix/
```

---

# Validation

Validation artifacts (kubectl outputs, logs, connectivity tests, before/after comparisons) are stored under each problem’s validation directory:

- troubleshooting/problem-1-networkpolicy-dns/validation/  
- troubleshooting/problem-2-service-dns-and-endpoints/validation/  
- troubleshooting/problem-3-memory-oom/validation/  
- troubleshooting/problem-4-networkpolicy-dns/validation/  

Grafana screenshots:

```
screenshots/grafana/
```

Exported Grafana dashboard JSON:

```
scripts/grafana-dashboard.json
```

All command outputs are saved as `.txt` files inside the diagnostics/ and validation/ folders.

---

# Summary of Fixes

- Allowed DNS traffic in NetworkPolicy  
- Corrected BACKEND_URL environment variable in frontend  
- Fixed backend Service selector so endpoints populate  
- Increased frontend memory limits to prevent OOMKilled  
- Installed kube-prometheus-stack and captured monitoring evidence  
- Added PromQL queries and dashboard analysis in docs/GRAFANA.md  

---

# Deliverables

- environment/before-fix/ — broken manifests  
- environment/after-fix/ — fixed manifests  
- troubleshooting/* — diagnostics, fixes, validation  
- scripts/ — deployment, monitoring, cleanup, debugging scripts  
- docs/REPORT.md — final report  
- docs/RCA.md  
- docs/IMPROVEMENTS.md  
- docs/GRAFANA.md  
- screenshots/grafana/ — dashboard screenshots  
- scripts/grafana-dashboard.json — exported dashboard  

---

# Recommended Review Order

1. docs/REPORT.md  
2. docs/RCA.md  
3. troubleshooting/problem-*/diagnostics/  
4. environment/before-fix/  
5. environment/after-fix/  
6. troubleshooting/problem-*/validation/  
7. screenshots/grafana/  
8. docs/GRAFANA.md  

---

# Cleanup

To delete all deployed resources:

```bash
cd scripts
./cleanup.sh
```