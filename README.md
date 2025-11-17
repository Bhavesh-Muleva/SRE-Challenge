# Atlan — SRE-II Challenge (Final Submission)

**Author:** Bhavesh Muleva  
**Date:** 2025

A reproducible SRE challenge repository that simulates a broken Kubernetes environment (4 deliberate failures), documents diagnostics, applies fixes, validates results, and includes monitoring evidence.

---

## Status
- Broken environment and fixes implemented ✅  
- Diagnostics, fixes and validation artifacts included ✅  
- Grafana dashboard screenshots + exported JSON included ✅  
- Report, RCA, Improvements, and Grafana docs included ✅

> Report format: `REPORT.md` (Markdown). Markdown is acceptable for submission; PDF is optional.

---

## Quick index (what reviewers will want to look at)

- `environment/before-fix/` — manifests that create the broken state.  
- `environment/after-fix/` — manifests with fixes applied.  
- `troubleshooting/` — per-problem `diagnostics/`, `fix/`, `validation/` folders.  
- `scripts/` — automation:
  - `deploy-broken.sh` — deploy the broken environment
  - `deploy-fixed.sh` — apply fixes
  - `install-monitoring.sh` — install kube-prometheus-stack + metrics-server
  - `cleanup.sh` — tear down resources
  - `test-connectivity.sh` — quick connectivity checks
  - `debug-commands.md` — common troubleshooting commands
  - `grafana-dashboard.json` — exported dashboard JSON
- `docs/` — `REPORT.md`, `RCA.md`, `IMPROVEMENTS.md`, `GRAFANA.md`
- `screenshots/grafana/` — Grafana screenshots used as evidence

---

## Prerequisites

- `kubectl` configured to target the cluster (kind, minikube, or cloud cluster)  
- `helm` (v3) installed for monitoring stack (optional for core troubleshooting)  
- `bash` / POSIX shell

If using `kind` (recommended for local evaluation):

```bash
# create kind cluster (optional)
cd cluster
./create-cluster.sh
How to reproduce (minimal reviewer steps)
Deploy the broken environment

bash
Copy code
cd scripts
./deploy-broken.sh
# wait a few seconds for pods to start
kubectl get pods -o wide
(Optional) Install monitoring

bash
Copy code
# inside scripts/ (this installs Prometheus + Grafana + metrics-server)
./install-monitoring.sh
# then port-forward Grafana:
kubectl port-forward -n monitoring svc/kube-prom-stack-grafana 3000:80
# visit http://localhost:3000 (user: admin / password: prom-operator)
Run diagnostics
The full command list used is in scripts/debug-commands.md.
All diagnostic output captured during my work is in the troubleshooting/ directories. Reviewers can open those .txt files to see the exact kubectl outputs and logs.

Apply fixes

bash
Copy code
# apply fixes (manifests under environment/after-fix)
./deploy-fixed.sh
Validate

Validation artifacts (command outputs) are stored under each problem's validation/ folder in troubleshooting/.

Grafana screenshots are in screenshots/grafana/.

Key files:

troubleshooting/problem-1-networkpolicy-dns/validation/*

troubleshooting/problem-2-service-dns-and-endpoints/validation/*

troubleshooting/problem-3-memory-oom/validation/*

troubleshooting/problem-4-networkpolicy-dns/validation/*

What I changed (high level)
Allowed DNS traffic in NetworkPolicy (fix for DNS blocking)

Corrected frontend BACKEND_URL environment variable

Fixed backend Service selector so endpoints populate

Increased frontend memory limits to prevent OOMKilled

Added monitoring via kube-prometheus-stack and captured evidence in Grafana screenshots

Full technical details, PromQL queries and screenshots documented in docs/GRAFANA.md.

Deliverables (what I included)
environment/before-fix/ — broken manifests

environment/after-fix/ — fixed manifests

troubleshooting/* — diagnostics, fixes, validation artifacts (per problem)

scripts/ — automation and debug commands

docs/REPORT.md — final report (Markdown)

docs/RCA.md, docs/IMPROVEMENTS.md, docs/GRAFANA.md

screenshots/grafana/ — 5 screenshots showing the monitoring evidence

scripts/grafana-dashboard.json — exported Grafana dashboard JSON

Recommended order for reviewers
Open docs/REPORT.md (high-level summary)

Read docs/RCA.md (root cause analysis)

Inspect troubleshooting/problem-*/diagnostics/* files to see raw evidence

Inspect environment/before-fix/ to understand the broken manifests

Inspect environment/after-fix/ for the actual fixes

Confirm via troubleshooting/problem-*/validation/* that fixes applied cleanly

Check Grafana screenshots in screenshots/grafana/ and docs/GRAFANA.md

Notes for evaluators
The main report is provided as Markdown (docs/REPORT.md). Markdown is acceptable because it is human-readable in GitHub; generating a PDF is optional. If you prefer a PDF, I can export REPORT.md to REPORT.pdf on request.

All kubectl outputs used as evidence are included as .txt files inside the appropriate troubleshooting/*/diagnostics and troubleshooting/*/validation folders.

Cleanup
To delete deployed resources:

bash
Copy code
cd scripts
./cleanup.sh