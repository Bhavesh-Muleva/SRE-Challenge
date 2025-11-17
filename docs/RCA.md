# 1. Executive Summary

The microservices-based application experienced multiple concurrent failures that caused:

- DNS lookup failures  
- Service discovery failures  
- Frontend unable to reach backend  
- Backend unreachable due to wrong service selector  
- Frontend repeatedly restarting due to OOMKilled  

The combined effect resulted in a **full service outage**.  
All issues were diagnosed, fixed, and validated using Kubernetes troubleshooting practices and monitoring tools.

---

# 2. Incident Timeline

| Time | Event |
|------|--------|
| T0 | Broken cluster deployed (intentional challenge state) |
| T1 | Frontend logs show DNS failures (`could not resolve host`) |
| T2 | NSLookup from debug pod confirms cluster-wide DNS egress blockage |
| T3 | Incorrect BACKEND_URL identified via init container logs |
| T4 | Backend service endpoints show `<none>` |
| T5 | Backend Deployment labels mismatched with Service selector |
| T6 | Frontend enters CrashLoopBackOff with `OOMKilled` |
| T7 | DNS allowed, backend URL fixed, service selector corrected |
| T8 | Memory limits increased, OOM resolved |
| T9 | System validated as healthy |

---

# 3. Root Causes

This environment contained **4 independent root causes**.

---

## **Root Cause 1 — DNS Failure due to Blocked Port 53**
### Technical Summary
- A NetworkPolicy prevented egress traffic to:
UDP 53
TCP 53

- All pod DNS queries flow through kube-dns (CoreDNS) at `10.96.0.10`.  
- With DNS blocked, both internal and external lookups failed.

### Evidence
- `nslookup google.com` → timeout  
- `nslookup backend-svc` → timeout  
- NetworkPolicy inspection showed no DNS ports allowed.

### Impact
- Service discovery broken  
- Init container unable to resolve backend  
- Frontend stuck in retry loops  

---

## **Root Cause 2 — Incorrect BACKEND_URL in Frontend**
### Technical Summary
Frontend Deployment contained:

BACKEND_URL=http://backend-svc-wrong.default.svc.cluster.local

### Evidence
Init container logs:
curl: (6) Could not resolve host: backend-svc-wrong


### Impact
- Even after DNS was fixed, frontend could not reach backend.  
- Caused unnecessary debug complexity until corrected.

---

## **Root Cause 3 — Backend Service Had No Endpoints**
### Technical Summary

Backend Deployment labels:
app: backend-app

Backend Service selector:
selector:
app: backend

Mismatch caused:
kubectl get ep backend-svc ⇒ <none>

### Impact
- Service existed but pointed to zero pods  
- Client compatibility broken  
- Curl requests hung or failed instantly  

---

## **Root Cause 4 — Frontend OOMKilled**
### Technical Summary

Frontend used a memory bomb workload:

dd if=/dev/zero of=/dev/shm/fill bs=1M count=50


Memory limits:
requests: 20Mi
limits: 30Mi


### Evidence
`kubectl describe pod`:

Last State:
Reason: OOMKilled
Exit Code: 137


### Impact
- Frontend repeatedly restarted  
- High restart counts  
- No traffic served  

---

# 4. Contributing Factors

| Factor | Description |
|--------|-------------|
| Misconfigured NetworkPolicy | Too strict and lacked DNS exceptions |
| No validation in CI/CD | No rule to prevent wrong selectors |
| No readiness probes | Frontend considered healthy despite downstream failures |
| Low memory limits | Unmatched to application behavior |
| Lack of monitoring alerts | No alerting for OOM or DNS failures |

---

# 5. Corrective Actions (Fixes Applied)

### ✔ Fix 1: Allow DNS in NetworkPolicy  
Both TCP/UDP port 53 allowed.

### ✔ Fix 2: Correct BACKEND_URL  
Changed to:
http://backend-svc.default.svc.cluster.local


### ✔ Fix 3: Fix Backend Service Selector  
Deployment labels and service selectors now match:
app: backend


### ✔ Fix 4: Increase Frontend Memory Limits  
Updated to:
requests: 128Mi
limits: 256Mi


All fixes applied via:

scripts/deploy-fixed.sh

---

# 6. Validation Summary

Validation steps matched expectations:

- `nslookup google.com` → Success  
- `nslookup backend-svc` → Success  
- `kubectl get ep backend-svc` → Endpoint present  
- Frontend logs show successful backend calls  
- No OOMKilled events after memory increase  
- Pod restarts = 0  
- Grafana dashboards confirm stable state  

Artifacts stored under:

troubleshooting/problem-*/validation/

---

# 7. Long-Term Preventive Actions (Future Improvements)

| Improvement | Benefit |
|-------------|---------|
| Add Kyverno/OPA policies | Prevent wrong selectors & enforce resource limits |
| Apply PodDisruptionBudgets | Prevent cascading pod failures |
| Implement liveness/readiness probes | Ensure frontend routes traffic only when ready |
| Add monitoring alerts | Detect OOM, DNS failure, service endpoint issues |
| Add traceability in CI/CD | Catch misconfigurations before deployment |
| Add service mesh retries | Make frontend more resilient to backend failures |

---

# 8. Final Status

All issues have been resolved.  
The system is **stable**, **monitored**, and **properly configured**.

System State: HEALTHY
All Services: RUNNING
No Restarts / No OOM / No DNS Errors