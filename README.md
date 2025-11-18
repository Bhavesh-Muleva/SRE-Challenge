# SRE-II Challenge
**Cluster Type:** Kind (Kubernetes-in-Docker)  
**Monitoring Stack:** kube-prometheus-stack (Prometheus + Grafana)

This repository contains the full solution to the Atlan SRE-II Challenge, including a simulated broken Kubernetes environment, diagnostics, fixes, validation evidence, monitoring outputs, and a structured final report.

The challenge involved **four Kubernetes failures which caused outage**, all of which were reproduced, debugged, fixed, and verified.

---

## 1. Repository Structure

├── environment/
│ ├── before-fix/ # Broken manifests used to simulate the failures
│ └── after-fix/ # Final working manifests
│
├── scripts/ # Deployment, monitoring stack, and test helpers
│ ├── deploy-broken.sh
│ ├── deploy-fixed.sh
│ ├── install-monitoring.sh
│ 
│
├── screenshots/ # Grafana Dashboard Screenshot
│
├── troubleshooting/
│ ├── problem-1-networkpolicy-dns/
│ │ ├── diagnostics/
│ │ ├── fix/
│ │ └── validation/
│ │
│ ├── problem-2-service-dns/
│ │ ├── diagnostics/
│ │ ├── fix/
│ │ └── validation/
│ │
│ ├── problem-3-service-endpoints/
│ │ ├── diagnostics/
│ │ ├── fix/
│ │ └── validation/
│ │
│ └── problem-4-memory-oom/
│ ├── diagnostics/
│ ├── fix/
│ └── validation/

---

Detailed explanations for all issues are available in:
```bash
REPORT.md
```

---

Each problem folder contains:

- **diagnostics/** — All commands and evidence collected before applying the fix  
- **fix/** — Corrected manifests and configuration  
- **validation/** — Outputs proving the issue was resolved  

---

### **Problem 1 — NetworkPolicy Blocking DNS**
- CoreDNS unreachable due to blocked UDP/TCP 53
- Breakage: frontend couldn't resolve backend service
- Fix: Updated NetworkPolicy to allow DNS egress traffic

### **Problem 2 — Incorrect Backend Service Name**
- The frontend Deployment referenced `backed` instead of `backend`
- Breakage: DNS resolution failed inside frontend pod
- Fix: Corrected the env variable and Deployment manifest

### **Problem 3 — Service Selector Mismatch (Empty Endpoints)**
- Backend Service selected wrong label (`app: backend` vs `app: backend-api`)
- Breakage: Service had zero endpoints
- Fix: Updated backend Service selector to match pod labels

### **Problem 4 — OOMKilled (Insufficient Memory Limits)**
- Frontend repeatedly restarted due to low memory limit
- Breakage: CrashLoopBackOff
- Fix: Increased memory limits and requests; redeployed


---

How to Reproduce the Environment

### Step 1 — Create a Kind cluster
```bash
kind create cluster --config kind-config.yaml
```
### Step 2 — Deploy the broken environment
```bash
bash scripts/deploy-broken.sh
```
### Step 3 — Install monitoring stack
```bash
bash scripts/install-monitoring.sh
```
Grafana becomes available at:
```bash
http://localhost:3000/
```