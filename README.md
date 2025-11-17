Atlan SRE-II Challenge – Final Submission

Author: Bhavesh Muleva
Tech Stack: Kubernetes, Prometheus, Grafana, Kind, Bash, YAML
Status: Fully Completed ✔

📌 Overview

This repository contains the complete solution for the Atlan SRE-II Challenge.
It includes:

A full simulated broken microservices environment (4 failures)

A fully working fixed environment

Rich diagnostic evidence, root cause analysis, and validation

Automated scripts to deploy, fix, and monitor the cluster

Grafana dashboards, screenshots, and documented metrics

A polished final report, RCA, and SRE improvements

Everything is structured according to real SRE incident response flows:

Observe the failure

Diagnose

Reproduce

Fix

Validate

Improve reliability

📁 Repository Structure
.
├── cluster/                     # Kind cluster creation & deletion scripts
│   ├── create-cluster.sh
│   ├── delete-cluster.sh
│   └── kind-config.yaml
│
├── environment/
│   ├── before-fix/             # ❌ Broken manifests (all 4 issues)
│   └── after-fix/              # ✅ Corrected manifests
│
├── troubleshooting/             # 🔍 Diagnostics, fixes, validation
│   ├── problem-1-networkpolicy-dns/
│   ├── problem-2-service-dns-and-endpoints/
│   ├── problem-3-memory-oom/
│   └── problem-4-networkpolicy-dns/
│
├── scripts/                     # 🛠 Automation
│   ├── deploy-broken.sh
│   ├── deploy-fixed.sh
│   ├── install-monitoring.sh
│   ├── cleanup.sh
│   ├── test-connectivity.sh
│   ├── debug-commands.md
│   ├── grafana-dashboard.json
│   └── monitoring-stack-config.yaml
│
├── docs/                        # 📘 Final documentation
│   ├── REPORT.md                # Full submission report
│   ├── RCA.md                   # Root Cause Analysis
│   ├── IMPROVEMENTS.md          # SRE improvements after fixes
│   └── GRAFANA.md               # Dashboards + PromQL + screenshots info
│
├── screenshots/
│   └── grafana/                 # 📊 Grafana dashboards (all included)
│
└── README.md                    # 📄 This file

⚠️ The 4 Issues Simulated
1️⃣ NetworkPolicy blocking DNS

Blocked UDP/TCP 53

Frontend init container failed on nslookup

Fixed by adding DNS ports to allowed egress

2️⃣ Wrong backend service name + missing endpoints

Environment variable pointed to backend-svc-wrong

Backend service selector mismatched → no endpoints

Fixed service selector + corrected backend URL

3️⃣ OOMKilled in frontend

Busybox process created infinite memory load

Container killed with exit code 137

Fixed by raising memory limits to realistic values

4️⃣ Incorrect readiness in init-container chain

Init container blocked boot due to earlier failures

Fixed after DNS + backend service issues resolved

🧪 How to Deploy, Test, and Fix
1. Create the cluster
cd cluster/
./create-cluster.sh

2. Deploy the broken environment
cd scripts/
./deploy-broken.sh


This will deploy:

Broken backend

Broken frontend

Wrong service

DNS-blocking NetworkPolicy

3. Install monitoring (Prometheus + Grafana + Metrics Server)
./install-monitoring.sh


All values are in:
scripts/monitoring-stack-config.yaml

4. Investigate issues

Run commands from:

scripts/debug-commands.md


All diagnostic outputs are already stored under:

troubleshooting/problem-*/diagnostics/

5. Apply fixes
./deploy-fixed.sh


All corrected manifests stored in:

environment/after-fix/

6. Validate

Validation commands + outputs saved under:

troubleshooting/problem-*/validation/

📊 Grafana Dashboards (Monitoring Evidence)

Dashboard screenshots stored in:

screenshots/grafana/


You included 5 key panels as required:

Cluster overview

Pod memory usage

Pod restart count

Node resource usage

OOMKilled events

Documentation + PromQL queries are in:

docs/GRAFANA.md


A dashboard export JSON is in:

scripts/grafana-dashboard.json

📄 Final Documentation (Evaluator Should Read)

Located in docs/:

File	Purpose
REPORT.md	Main submission report
RCA.md	Deep dive Root Cause Analysis
IMPROVEMENTS.md	Reliability & SRE improvements
GRAFANA.md	Dashboards, panels, queries & evidence