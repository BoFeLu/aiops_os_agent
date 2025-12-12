# AIOps OS Agent

Enterprise-grade AIOps (Artificial Intelligence for IT Operations) agent for intelligent system monitoring and operations automation. Built with security-first principles and deployed on hardened Kubernetes infrastructure.

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Python Version](https://img.shields.io/badge/python-3.9%2B-blue)](https://www.python.org/downloads/)
[![Docker](https://img.shields.io/badge/docker-ready-blue)](https://www.docker.com/)
[![Kubernetes](https://img.shields.io/badge/kubernetes-ready-blue)](https://kubernetes.io/)

## 🌟 Features

### Core Capabilities
- **Real-time System Monitoring**: Comprehensive metrics collection for CPU, memory, disk, and network
- **Intelligent Anomaly Detection**: Automated detection of system anomalies with configurable thresholds
- **Alert Management**: Multi-channel alerting with webhook support
- **Scalable Architecture**: Designed for horizontal scaling in Kubernetes environments
- **Enterprise Security**: Hardened containers with non-root users, read-only filesystems, and minimal attack surface

### Security Features
- ✅ Non-root container execution
- ✅ Read-only root filesystem
- ✅ No privilege escalation
- ✅ Minimal container image (based on Python slim)
- ✅ Network policies for traffic isolation
- ✅ RBAC for Kubernetes access control
- ✅ Secrets management for sensitive data
- ✅ Security contexts at pod and container level

### Kubernetes Features
- ✅ Horizontal Pod Autoscaling (HPA)
- ✅ Pod Disruption Budgets (PDB)
- ✅ Resource limits and requests
- ✅ Liveness and readiness probes
- ✅ ConfigMaps for configuration
- ✅ Network policies
- ✅ Service mesh ready

## 📋 Table of Contents

- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
  - [Docker Deployment](#docker-deployment)
  - [Kubernetes Deployment](#kubernetes-deployment)
- [Configuration](#configuration)
- [Usage](#usage)
- [Monitoring](#monitoring)
- [Security](#security)
- [Development](#development)
- [Testing](#testing)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [License](#license)

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    AIOps Agent                          │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐ │
│  │   Metrics    │  │   Anomaly    │  │    Alert     │ │
│  │  Collector   │─▶│   Detector   │─▶│   Manager    │ │
│  └──────────────┘  └──────────────┘  └──────────────┘ │
│         │                  │                  │        │
│         ▼                  ▼                  ▼        │
│  ┌──────────────────────────────────────────────────┐ │
│  │            Configuration Manager                  │ │
│  └──────────────────────────────────────────────────┘ │
│                                                         │
└─────────────────────────────────────────────────────────┘
                         │
                         ▼
              ┌──────────────────────┐
              │   System Resources   │
              │  CPU │ MEM │ DISK │ NET
              └──────────────────────┘
```

### Components

1. **Metrics Collector**: Gathers system metrics using psutil
2. **Anomaly Detector**: Analyzes metrics against configurable thresholds
3. **Alert Manager**: Sends notifications when anomalies are detected
4. **Configuration Manager**: Handles environment-based configuration

## 📦 Prerequisites

### For Docker Deployment
- Docker 20.10+
- Docker Compose 1.29+ (optional)

### For Kubernetes Deployment
- Kubernetes 1.21+
- kubectl configured with cluster access
- Container registry access (for custom images)

### For Development
- Python 3.9+
- pip 21.0+
- Git

## 🚀 Installation

### Docker Deployment

#### Quick Start with Docker Compose

```bash
# Clone the repository
git clone https://github.com/BoFeLu/aiops_os_agent.git
cd aiops_os_agent

# Start the agent
docker-compose up -d

# View logs
docker-compose logs -f aiops-agent
```

#### Build and Run Manually

```bash
# Build the Docker image
docker build -t aiops-agent:1.0.0 .

# Run the container
docker run -d \
  --name aiops-agent \
  --user 1001:1001 \
  --security-opt=no-new-privileges:true \
  --cap-drop=ALL \
  --cap-add=NET_BIND_SERVICE \
  -e AGENT_NAME=my-agent \
  -e LOG_LEVEL=INFO \
  aiops-agent:1.0.0

# View logs
docker logs -f aiops-agent
```

### Kubernetes Deployment

#### Using Deployment Scripts

```bash
# Build and push Docker image (customize registry as needed)
export REGISTRY=your-registry.io
./scripts/build-docker.sh

# Deploy to Kubernetes
./scripts/deploy-k8s.sh

# Check deployment status
kubectl get pods -n aiops
kubectl logs -f deployment/aiops-agent -n aiops
```

#### Manual Deployment

```bash
# Apply all manifests
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/rbac.yaml
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/secret.yaml
kubectl apply -f k8s/network-policy.yaml
kubectl apply -f k8s/service.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/pdb.yaml
kubectl apply -f k8s/hpa.yaml

# Verify deployment
kubectl get all -n aiops
```

#### Undeploy from Kubernetes

```bash
./scripts/undeploy-k8s.sh
```

## ⚙️ Configuration

### Environment Variables

| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| `AGENT_NAME` | Name identifier for the agent | `aiops-agent` | No |
| `ENVIRONMENT` | Deployment environment | `production` | No |
| `COLLECTION_INTERVAL` | Metrics collection interval (seconds) | `60` | No |
| `LOG_LEVEL` | Logging level (DEBUG, INFO, WARNING, ERROR) | `INFO` | No |
| `LOG_FORMAT` | Log format (json, text) | `json` | No |
| `METRICS_EXPORT_ENABLED` | Enable metrics export | `true` | No |
| `ANOMALY_DETECTION_ENABLED` | Enable anomaly detection | `true` | No |
| `CPU_THRESHOLD` | CPU usage threshold (%) | `80.0` | No |
| `MEMORY_THRESHOLD` | Memory usage threshold (%) | `85.0` | No |
| `DISK_THRESHOLD` | Disk usage threshold (%) | `90.0` | No |
| `ALERT_ENABLED` | Enable alerting | `true` | No |
| `ALERT_WEBHOOK_URL` | Webhook URL for alerts | `""` | No |

### Kubernetes Configuration

Edit `k8s/configmap.yaml` to modify configuration:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: aiops-agent-config
  namespace: aiops
data:
  COLLECTION_INTERVAL: "60"
  CPU_THRESHOLD: "80.0"
  # ... other settings
```

For sensitive data, use `k8s/secret.yaml`:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: aiops-agent-secrets
  namespace: aiops
type: Opaque
stringData:
  ALERT_WEBHOOK_URL: "https://your-webhook-url.com"
```

## 📊 Usage

### Basic Operation

The agent runs continuously, collecting metrics at the configured interval and detecting anomalies:

1. **Metrics Collection**: Every `COLLECTION_INTERVAL` seconds
2. **Anomaly Detection**: Analyzes collected metrics against thresholds
3. **Alert Generation**: Sends alerts when anomalies are detected

### Viewing Logs

#### Docker
```bash
docker logs -f aiops-agent
```

#### Kubernetes
```bash
kubectl logs -f deployment/aiops-agent -n aiops
```

### Health Checks

The agent includes built-in health checks:

#### Docker
```bash
docker inspect --format='{{json .State.Health}}' aiops-agent
```

#### Kubernetes
```bash
kubectl get pods -n aiops
kubectl describe pod <pod-name> -n aiops
```

## 📈 Monitoring

### Metrics

The agent exposes the following metrics:

- **CPU Usage**: Percentage and per-core statistics
- **Memory Usage**: Total, available, used, and percentage
- **Disk Usage**: Total, used, free, and percentage
- **Network I/O**: Bytes and packets sent/received
- **System Uptime**: System and agent uptime

### Integration with Prometheus

The deployment includes Prometheus annotations for automatic discovery:

```yaml
annotations:
  prometheus.io/scrape: "true"
  prometheus.io/port: "8080"
  prometheus.io/path: "/metrics"
```

## 🔒 Security

### Container Security

- **Non-root User**: Runs as UID 1001
- **Read-only Filesystem**: Root filesystem is read-only
- **Dropped Capabilities**: All capabilities dropped, only essential ones added
- **No Privilege Escalation**: Prevents privilege escalation
- **Minimal Base Image**: Based on Python slim

### Kubernetes Security

- **RBAC**: Minimal permissions for service account
- **Network Policies**: Restricts network traffic
- **Security Contexts**: Pod and container-level security settings
- **Secrets Management**: Sensitive data in Kubernetes secrets
- **Pod Security Standards**: Enforces restricted pod security

### Security Best Practices

1. **Webhook URL**: Store webhook URLs in secrets, not configmaps
2. **Image Scanning**: Scan container images for vulnerabilities
3. **Network Policies**: Review and adjust network policies for your environment
4. **RBAC**: Audit service account permissions regularly
5. **Updates**: Keep base images and dependencies updated

## 🛠️ Development

### Setup Development Environment

```bash
# Clone the repository
git clone https://github.com/BoFeLu/aiops_os_agent.git
cd aiops_os_agent

# Create virtual environment
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt
pip install -r requirements-dev.txt

# Install in editable mode
pip install -e .
```

### Running Locally

```bash
# Set environment variables
export AGENT_NAME=dev-agent
export LOG_LEVEL=DEBUG
export COLLECTION_INTERVAL=30

# Run the agent
python -m aiops_agent.main
```

## 🧪 Testing

### Run Tests

```bash
# Install test dependencies
pip install -r requirements-dev.txt

# Run all tests
pytest

# Run with coverage
pytest --cov=aiops_agent --cov-report=html

# Run specific test file
pytest tests/test_metrics_collector.py

# Run with verbose output
pytest -v
```

### Test Coverage

The test suite includes:
- Unit tests for all modules
- Integration tests for the complete agent
- Configuration tests
- Security validation tests

## 🐛 Troubleshooting

### Common Issues

#### Agent Not Starting

```bash
# Check logs
kubectl logs deployment/aiops-agent -n aiops

# Check pod status
kubectl describe pod <pod-name> -n aiops
```

#### High Memory Usage

Adjust resource limits in `k8s/deployment.yaml`:

```yaml
resources:
  limits:
    memory: 512Mi  # Increase if needed
```

#### Alerts Not Sending

1. Verify webhook URL is configured in secret
2. Check network policies allow egress traffic
3. Review alert manager logs

#### Permission Errors

Ensure RBAC is correctly configured:

```bash
kubectl get serviceaccount aiops-agent -n aiops
kubectl get role aiops-agent -n aiops
kubectl get rolebinding aiops-agent -n aiops
```

### Debug Mode

Enable debug logging:

```bash
# Update configmap
kubectl edit configmap aiops-agent-config -n aiops
# Set LOG_LEVEL: "DEBUG"

# Restart deployment
kubectl rollout restart deployment/aiops-agent -n aiops
```

## 📝 Contributing

Contributions are welcome! Please follow these guidelines:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Ensure all tests pass
6. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Built with [psutil](https://github.com/giampaolo/psutil) for system metrics
- Containerized with Docker
- Orchestrated with Kubernetes
- Inspired by AIOps principles and best practices

## 📧 Support

For issues, questions, or contributions, please open an issue on GitHub.

---

**Note**: This is an enterprise-grade solution. Ensure you review and customize security settings, resource limits, and configurations for your specific environment before production deployment.
