# 📊 Grafana Monitoring Documentation  
Monitoring stack installed using:

scripts/install-monitoring.sh

Which deploys:

- Prometheus
- Alertmanager
- Grafana
- Node Exporter
- Kube State Metrics
- Metrics Server

---

# 1. Accessing Grafana

Grafana is exposed through the kube-prometheus-stack chart.

Expose it locally:

```bash
kubectl port-forward -n monitoring svc/kube-prom-stack-grafana 3000:80
```
Access:

http://localhost:3000


2. Dashboards Used for Troubleshooting
These dashboards were either imported or custom-created.
Screenshots of each dashboard are stored in:
```bash
screenshots/grafana/
Included screenshots:
01_cluster_overview.png
02_pod_memory_usage.png
03_pod_restart_count.png
04_node_resource_usage.png
OOMKilled (Last Terminated).png
```
3. Custom Panels & PromQL Queries
Below are the PromQL queries used to visualize the behavior of the broken system and validate fixes.

3.1 Pod Memory Usage (Used for OOM Analysis)
Shows per-container memory consumption.

PromQL:
```bash
container_memory_usage_bytes{container!="",pod!="",namespace="default"}
```
Used to diagnose:

OOMKilled frontend container

Memory spikes during OOM workload

3.2 Pod Memory Usage
Used to visualize memory spikes in the frontend pod and confirm the OOM issue.

PromQL:
```bash
container_memory_usage_bytes{container!="",pod!="",namespace="default"}
```
3.3 Pod Restart Count
Checks how many times problematic pods restarted.

PromQL:
```bash
kube_pod_container_status_restarts_total{namespace="default"}
```
Useful for:
Detecting CrashLoopBackOff
Backend readiness issues
Regression after fixes

3.4 Node Resource Usage (Make sure nodes not throttling)

(Built-in dashboard)

Node is healthy
No memory pressure conditions
No throttling impacting OOMKilled logic

3.5 OOMKilled Container Events
Shows which pods were terminated due to OOM.

PromQL:
```bash
kube_pod_container_status_last_terminated_reason{reason="OOMKilled"}
```
This clearly displays:

Frontend OOM events before fix
Zero OOM events after fixing memory limits

4. How Grafana Was Used to Validate Fixes
🟢 After DNS fix
DNS latency panel returned to normal

Zero failed requests

🟢 After backend service fix
Endpoint count became non-zero

Error rate panel dropped to zero

🟢 After OOM fix
Memory usage stable under new limits

No new OOMKilled events

🟢 After All Fixes
All services healthy

No restarts
