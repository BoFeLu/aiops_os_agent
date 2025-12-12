# Architecture Overview

This document provides a detailed architectural overview of the AIOps Agent system.

## System Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                         Kubernetes Cluster                          │
│                                                                     │
│  ┌──────────────────────────────────────────────────────────────┐ │
│  │                    AIOps Namespace                           │ │
│  │                                                              │ │
│  │  ┌────────────────────────────────────────────────────┐     │ │
│  │  │              AIOps Agent Pod                       │     │ │
│  │  │                                                    │     │ │
│  │  │  ┌──────────────┐  ┌──────────────┐  ┌─────────┐ │     │ │
│  │  │  │   Metrics    │  │   Anomaly    │  │ Alert   │ │     │ │
│  │  │  │  Collector   │→│   Detector   │→│ Manager │ │     │ │
│  │  │  └──────────────┘  └──────────────┘  └─────────┘ │     │ │
│  │  │         │                  │               │      │     │ │
│  │  │         ▼                  ▼               ▼      │     │ │
│  │  │  ┌────────────────────────────────────────────┐  │     │ │
│  │  │  │      Configuration Manager                 │  │     │ │
│  │  │  └────────────────────────────────────────────┘  │     │ │
│  │  │         │                  │               │      │     │ │
│  │  │         ▼                  ▼               ▼      │     │ │
│  │  │  ┌────────────────────────────────────────────┐  │     │ │
│  │  │  │         Logging & Monitoring               │  │     │ │
│  │  │  └────────────────────────────────────────────┘  │     │ │
│  │  └────────────────────────────────────────────────────┘     │ │
│  │                                                              │ │
│  │  ConfigMap          Secret           Service                │ │
│  │  NetworkPolicy      RBAC             HPA                    │ │
│  └──────────────────────────────────────────────────────────────┘ │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
                              │
                              ▼
                    External Systems
                   (Webhooks, Alerting)
```

## Component Architecture

### 1. Metrics Collector

**Purpose**: Collect system resource metrics

**Responsibilities**:
- CPU usage monitoring
- Memory utilization tracking
- Disk space monitoring
- Network I/O statistics
- System uptime tracking

**Technology**: Python `psutil` library

**Data Flow**:
```
System Resources → psutil API → Metrics Collector → Structured Metrics
```

**Output Format**:
```json
{
  "cpu": {
    "usage_percent": 45.2,
    "count": 4,
    "per_cpu": [42.0, 48.5, 44.1, 46.3]
  },
  "memory": {
    "total": 8589934592,
    "available": 4294967296,
    "used": 4294967296,
    "percent": 50.0
  },
  "disk": {
    "total": 107374182400,
    "used": 53687091200,
    "free": 53687091200,
    "percent": 50.0
  }
}
```

### 2. Anomaly Detector

**Purpose**: Identify abnormal system behavior

**Detection Methods**:
- Threshold-based detection
- Statistical analysis (future)
- Machine learning models (future)

**Thresholds**:
- CPU: Configurable (default 80%)
- Memory: Configurable (default 85%)
- Disk: Configurable (default 90%)

**Severity Levels**:
- **Warning**: Metric exceeds threshold but < 95%
- **Critical**: Metric exceeds 95%

**Data Flow**:
```
Metrics → Anomaly Detector → Anomaly List → Alert Manager
```

### 3. Alert Manager

**Purpose**: Send notifications for detected anomalies

**Notification Channels**:
- Webhook (HTTP POST)
- Future: Email, Slack, PagerDuty, ServiceNow

**Alert Format**:
```json
{
  "agent_name": "aiops-agent-prod",
  "environment": "production",
  "timestamp": "2025-12-12T08:00:00Z",
  "anomaly": {
    "type": "cpu_high",
    "severity": "warning",
    "message": "High CPU usage: 85.50%",
    "value": 85.5,
    "threshold": 80.0
  }
}
```

### 4. Configuration Manager

**Purpose**: Manage agent configuration

**Configuration Sources** (priority order):
1. Environment variables
2. Configuration files (future)
3. Default values

**Configuration Categories**:
- Agent identification
- Monitoring settings
- Anomaly detection thresholds
- Alerting configuration
- Logging settings

## Deployment Architecture

### Kubernetes Resources

```
Namespace: aiops
│
├── ServiceAccount: aiops-agent
│   └── RBAC: Role + RoleBinding
│
├── ConfigMap: aiops-agent-config
│   └── Non-sensitive configuration
│
├── Secret: aiops-agent-secrets
│   └── Sensitive data (webhook URLs, etc.)
│
├── Deployment: aiops-agent
│   ├── Replicas: 1 (scalable to 5 with HPA)
│   ├── Security Contexts
│   ├── Resource Limits
│   └── Health Probes
│
├── Service: aiops-agent
│   └── ClusterIP (port 8080)
│
├── NetworkPolicy: aiops-agent-network-policy
│   ├── Ingress: Prometheus (monitoring namespace)
│   └── Egress: DNS, HTTPS
│
├── HorizontalPodAutoscaler: aiops-agent-hpa
│   └── Min: 1, Max: 5, Target CPU: 70%
│
└── PodDisruptionBudget: aiops-agent-pdb
    └── MinAvailable: 1
```

### Container Architecture

**Base Image**: `python:3.11-slim`

**Multi-Stage Build**:
1. **Builder Stage**: Install dependencies
2. **Runtime Stage**: Copy artifacts, run as non-root

**Security Hardening**:
- Non-root user (UID 1001)
- Read-only root filesystem
- Minimal capabilities
- No privilege escalation

**Directory Structure**:
```
/app/
├── src/
│   └── aiops_agent/
│       ├── __init__.py
│       ├── main.py
│       ├── agent.py
│       ├── config.py
│       ├── metrics_collector.py
│       ├── anomaly_detector.py
│       ├── alerting.py
│       └── logging_config.py
├── logs/ (writable, emptyDir)
├── data/ (writable, emptyDir)
└── setup.py
```

## Data Flow

### Normal Operation

```
1. Agent Start
   └→ Load Configuration
      └→ Initialize Components
         └→ Start Monitoring Loop

2. Monitoring Loop (every COLLECTION_INTERVAL seconds)
   └→ Collect Metrics
      └→ Detect Anomalies
         └→ Send Alerts (if anomalies found)
            └→ Export Metrics
               └→ Sleep until next interval

3. Graceful Shutdown
   └→ Receive SIGTERM/SIGINT
      └→ Stop monitoring loop
         └→ Cleanup resources
            └→ Exit
```

### Error Handling

```
Error Occurs
└→ Log Error
   └→ Continue Operation (resilient)
      └→ Retry on next iteration
```

## Scaling Architecture

### Horizontal Scaling

**HPA Configuration**:
- Minimum replicas: 1
- Maximum replicas: 5
- Scale up: CPU > 70% or Memory > 80%
- Scale down: Gradual (50% every 5 minutes)

**Considerations**:
- Each pod monitors the same system (node)
- For multi-node monitoring, use DaemonSet instead
- State is ephemeral (no shared state)

### Vertical Scaling

**Resource Adjustments**:
```yaml
resources:
  requests:
    cpu: 100m → 200m
    memory: 128Mi → 256Mi
  limits:
    cpu: 500m → 1000m
    memory: 512Mi → 1Gi
```

## Network Architecture

### Network Policies

**Ingress Rules**:
- Allow from: `monitoring` namespace (Prometheus)
- Protocol: TCP
- Port: 8080

**Egress Rules**:
- DNS: UDP 53 (kube-system namespace)
- HTTPS: TCP 443 (for webhooks)
- HTTP: TCP 80 (optional)

### Service Mesh Integration (Optional)

Compatible with:
- Istio
- Linkerd
- Consul Connect

**Benefits**:
- mTLS encryption
- Advanced traffic management
- Enhanced observability
- Circuit breaking

## Security Architecture

### Defense in Depth

```
Layer 1: Network (NetworkPolicy, Service Mesh)
   └→ Layer 2: Pod (SecurityContext, RBAC)
      └→ Layer 3: Container (Non-root, Read-only FS)
         └→ Layer 4: Application (Input validation, secure coding)
            └→ Layer 5: Data (Secrets, encryption)
```

### Trust Boundaries

```
External Systems ←→ Kubernetes Cluster ←→ AIOps Namespace ←→ Pod ←→ Container
   (Untrusted)         (Cluster Admin)      (Namespace Admin)  (App)  (Process)
```

## Monitoring & Observability

### Metrics

**Application Metrics**:
- System CPU, Memory, Disk, Network
- Anomaly count
- Alert count

**Container Metrics**:
- CPU usage
- Memory usage
- Restart count

**Kubernetes Metrics**:
- Pod status
- Deployment status
- HPA status

### Logging

**Log Levels**:
- DEBUG: Detailed diagnostic information
- INFO: General informational messages
- WARNING: Warning messages, anomalies
- ERROR: Error messages
- CRITICAL: Critical issues

**Log Format** (JSON):
```json
{
  "timestamp": "2025-12-12T08:00:00Z",
  "level": "INFO",
  "logger": "aiops_agent.agent",
  "message": "Metrics collected successfully"
}
```

### Health Checks

**Liveness Probe**:
- Ensures pod is alive
- Frequency: Every 30s
- Failure: Restart pod

**Readiness Probe**:
- Ensures pod can serve traffic
- Frequency: Every 10s
- Failure: Remove from service

## Future Enhancements

### Short-term (v1.1)
- Prometheus metrics endpoint
- Grafana dashboards
- Email alerting
- Configuration hot-reload

### Medium-term (v2.0)
- Machine learning anomaly detection
- Historical data storage
- REST API for querying
- Multi-node monitoring with DaemonSet

### Long-term (v3.0)
- Automated remediation
- Predictive analytics
- Integration with ITSM tools
- Custom plugin system

## Performance Characteristics

### Resource Usage

**Typical**:
- CPU: 50-100m
- Memory: 100-200Mi
- Network: Minimal (webhook calls only)

**Under Load**:
- CPU: Up to 500m (limit)
- Memory: Up to 512Mi (limit)

### Scalability

- **Vertical**: Up to 2 CPUs, 2Gi memory
- **Horizontal**: 1-5 replicas (configurable)
- **Monitoring Capacity**: Handles 1000s of metrics/second

## Technology Stack

### Runtime
- Python 3.9+
- psutil 5.9+
- PyYAML 6.0+
- requests 2.31+

### Infrastructure
- Docker 20.10+
- Kubernetes 1.21+
- Linux kernel 4.x+

### Monitoring
- Prometheus (optional)
- Grafana (optional)
- ELK/EFK stack (optional)

## References

- [Kubernetes Best Practices](https://kubernetes.io/docs/concepts/configuration/overview/)
- [12-Factor App Methodology](https://12factor.net/)
- [Cloud Native Computing Foundation](https://www.cncf.io/)
