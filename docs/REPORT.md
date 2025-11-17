# 📝 SRE-II Challenge — Final Report

---

# 1. Objective

The objective of this challenge was to analyze a deliberately broken microservices environment, diagnose issues across networking, service discovery, resource management, and configuration, and restore the system to a healthy state.  
The focus areas included:

- Kubernetes troubleshooting  
- Service connectivity & DNS  
- Resource bottlenecks (OOM)  
- NetworkPolicy impact analysis  
- SRE-style RCA, validation, and improvements  

My approach followed real-world SRE principles: **observe → diagnose → isolate → fix → validate → improve**.

---

# 2. Summary of Issues Identified

During the investigation, four independent failures were identified:

### **Issue 1 — DNS Failure (NetworkPolicy Blocked Port 53)**  
- A restrictive egress policy prevented pods from accessing `kube-dns` (10.96.0.10).  
- Result: All DNS lookups failed (`nslookup google.com` and internal `backend-svc`).

### **Issue 2 — Wrong BACKEND_URL in Frontend Deployment**  
- Frontend was configured to talk to a non-existent DNS name:  
  `http://backend-svc-wrong.default.svc.cluster.local`  
- Result: Curl repeatedly failed with “Could not resolve host”.

### **Issue 3 — Backend Service Had No Endpoints**  
- Backend Deployment labels: `app: backend-app`  
- Backend Service selector: `app: backend`  
- Result: No endpoints → frontend could not connect even after DNS was fixed.

### **Issue 4 — Frontend Container OOMKilled**  
- Busybox memory workload consumed RAM extremely fast.  
- Limits were too low: `20Mi/30Mi`.  
- Result: Pod repeatedly entered `CrashLoopBackOff` with `OOMKilled (137)`.

---

# 3. Steps Taken

## **Step 1 — Deployed Broken Environment**
Used automated script:

scripts/deploy-broken.sh

This intentionally introduced:

- DNS failure  
- Wrong backend URL  
- No backend endpoints  
- OOM workload  

---

## **Step 2 — Performed Systematic Troubleshooting**

For each issue:

### 🔍 2.1 DNS Failure
nslookup google.com
nslookup backend-svc

Both failed → confirmed DNS outage.

### 🔍 2.2 Wrong Service Name
Init container log clearly showed:

curl: (6) Could not resolve host: backend-svc-wrong

### 🔍 2.3 No Backend Endpoints
kubectl get ep backend-svc

Returned `<none>` → confirmed selector mismatch.

### 🔍 2.4 OOMKilled Frontend
kubectl describe pod frontend | grep -A4 OOM
kubectl logs frontend --previous

Showed `OOMKilled`.

Diagnostics were stored under:

troubleshooting/problem-*/diagnostics/

---

## **Step 3 — Applied Fixes**

### ✔ Fix 1: Allowed DNS in NetworkPolicy  
Opened TCP+UDP port 53.

### ✔ Fix 2: Corrected BACKEND_URL  
Updated env to:

http://backend-svc.default.svc.cluster.local


### ✔ Fix 3: Fixed Backend Service Selector  
Deployment + Service labels matched (`app: backend`).

### ✔ Fix 4: Increased Frontend Memory Limits  
Raised limits to:

requests: 128Mi
limits: 256Mi

---

# 4. Validation Performed

After applying the fixes using:

scripts/deploy-fixed.sh

Performed:

### 🔹 DNS Validation
nslookup google.com
nslookup backend-svc

Both successful.

### 🔹 Backend Service Validation
kubectl get ep backend-svc

Endpoints populated.

### 🔹 Frontend Connectivity
kubectl logs -l app=frontend -c frontend
curl http://backend-svc.default.svc.cluster.local

Successful response.

### 🔹 Memory Stability
kubectl top pod -l app=frontend

No OOM incidents after fix.

Validation artifacts stored under:

troubleshooting/problem-*/validation/

---

# 5. Metrics & Monitoring Setup

Monitoring stack deployed using:

scripts/install-monitoring.sh

This installed:

- kube-prometheus-stack (Prometheus + Grafana)
- metrics-server  
- Custom values from `monitoring-stack-config.yaml`

Grafana dashboards validated:

- Pod memory usage  
- Node CPU/memory usage  
- Pod restarts  
- Kube API latency  
Screenshots stored under:

screenshots/

---

# 6. Final State

After all fixes:

- System fully functional  
- No DNS issues  
- Frontend successfully communicates with backend  
- No CrashLoopBackOff  
- OOM resolved  
- Services stable and discoverable  
- Monitoring operational  

---

# 7. SRE Improvements (High Impact)

### **1. Add Probes**
Add readiness/liveness probes to backend + frontend.

### **2. Enforce Resource Policies**
Use Kyverno/OPA to prevent OOM-prone containers.

### **3. Add Alerts**
Prometheus alerts for:

- Pod OOMKilled  
- CrashLoopBackOff  
- DNS Latency  
- Service endpoint stinginess  

### **4. CI/CD Validation**
Use admission checks to:

- Block misconfigured services  
- Block wrong selectors  
- Validate NetworkPolicy reachability  

### **5. Add Service Mesh (optional)**
Use Istio linkerd for retries + metrics.

---