# Installation Guide

This guide provides detailed instructions for installing and deploying the AIOps Agent in various environments.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Docker Installation](#docker-installation)
- [Kubernetes Installation](#kubernetes-installation)
- [Configuration](#configuration)
- [Verification](#verification)

## Prerequisites

### System Requirements

- **Operating System**: Linux (Ubuntu 20.04+, CentOS 8+, RHEL 8+)
- **Architecture**: x86_64 / AMD64
- **Memory**: Minimum 256MB RAM (512MB recommended)
- **CPU**: Minimum 1 core (2 cores recommended)

### Software Requirements

#### For Docker Deployment
- Docker Engine 20.10 or later
- Docker Compose 1.29 or later (optional)

#### For Kubernetes Deployment
- Kubernetes cluster 1.21 or later
- kubectl CLI tool configured with cluster access
- Helm 3.x (optional, for advanced deployments)

## Docker Installation

### Method 1: Using Docker Compose (Recommended)

1. **Clone the repository**:
   ```bash
   git clone https://github.com/BoFeLu/aiops_os_agent.git
   cd aiops_os_agent
   ```

2. **Configure environment** (optional):
   Edit `docker-compose.yml` to customize environment variables.

3. **Start the agent**:
   ```bash
   docker-compose up -d
   ```

4. **Verify deployment**:
   ```bash
   docker-compose ps
   docker-compose logs -f aiops-agent
   ```

### Method 2: Using Docker CLI

1. **Build the image**:
   ```bash
   cd aiops_os_agent
   docker build -t aiops-agent:1.0.0 .
   ```

2. **Run the container**:
   ```bash
   docker run -d \
     --name aiops-agent \
     --user 1001:1001 \
     --security-opt=no-new-privileges:true \
     --cap-drop=ALL \
     --cap-add=NET_BIND_SERVICE \
     --restart=unless-stopped \
     -e AGENT_NAME=my-agent \
     -e LOG_LEVEL=INFO \
     -e COLLECTION_INTERVAL=60 \
     aiops-agent:1.0.0
   ```

3. **Verify deployment**:
   ```bash
   docker ps | grep aiops-agent
   docker logs -f aiops-agent
   ```

## Kubernetes Installation

### Prerequisites

Before deploying to Kubernetes:

1. **Verify cluster access**:
   ```bash
   kubectl cluster-info
   kubectl get nodes
   ```

2. **Create container registry secret** (if using private registry):
   ```bash
   kubectl create secret docker-registry regcred \
     --docker-server=<your-registry> \
     --docker-username=<username> \
     --docker-password=<password> \
     --docker-email=<email> \
     -n aiops
   ```

### Method 1: Using Deployment Script (Recommended)

1. **Clone the repository**:
   ```bash
   git clone https://github.com/BoFeLu/aiops_os_agent.git
   cd aiops_os_agent
   ```

2. **Build and push Docker image**:
   ```bash
   export REGISTRY=your-registry.io
   export IMAGE_TAG=1.0.0
   ./scripts/build-docker.sh
   ```

3. **Update image reference** in `k8s/deployment.yaml`:
   ```yaml
   image: your-registry.io/aiops-agent:1.0.0
   ```

4. **Deploy to Kubernetes**:
   ```bash
   ./scripts/deploy-k8s.sh
   ```

5. **Verify deployment**:
   ```bash
   kubectl get all -n aiops
   kubectl logs -f deployment/aiops-agent -n aiops
   ```

### Method 2: Manual Deployment

1. **Create namespace**:
   ```bash
   kubectl apply -f k8s/namespace.yaml
   ```

2. **Configure secrets**:
   Edit `k8s/secret.yaml` and add your webhook URL:
   ```yaml
   stringData:
     ALERT_WEBHOOK_URL: "https://your-webhook.example.com"
   ```

3. **Deploy resources** in order:
   ```bash
   kubectl apply -f k8s/rbac.yaml
   kubectl apply -f k8s/configmap.yaml
   kubectl apply -f k8s/secret.yaml
   kubectl apply -f k8s/network-policy.yaml
   kubectl apply -f k8s/service.yaml
   kubectl apply -f k8s/deployment.yaml
   kubectl apply -f k8s/pdb.yaml
   kubectl apply -f k8s/hpa.yaml
   ```

4. **Verify deployment**:
   ```bash
   kubectl get pods -n aiops
   kubectl describe deployment aiops-agent -n aiops
   kubectl logs -f deployment/aiops-agent -n aiops
   ```

## Configuration

### Basic Configuration

Edit `k8s/configmap.yaml` before deployment:

```yaml
data:
  AGENT_NAME: "aiops-agent-prod"
  COLLECTION_INTERVAL: "60"
  CPU_THRESHOLD: "80.0"
  MEMORY_THRESHOLD: "85.0"
  DISK_THRESHOLD: "90.0"
```

### Advanced Configuration

For production environments:

1. **Resource Limits**: Adjust in `k8s/deployment.yaml`:
   ```yaml
   resources:
     requests:
       cpu: 100m
       memory: 128Mi
     limits:
       cpu: 500m
       memory: 512Mi
   ```

2. **Autoscaling**: Configure in `k8s/hpa.yaml`:
   ```yaml
   spec:
     minReplicas: 1
     maxReplicas: 5
     metrics:
     - type: Resource
       resource:
         name: cpu
         target:
           type: Utilization
           averageUtilization: 70
   ```

3. **Network Policies**: Review and adjust `k8s/network-policy.yaml` based on your cluster setup.

## Verification

### Health Check

**Docker**:
```bash
docker inspect --format='{{json .State.Health}}' aiops-agent | jq
```

**Kubernetes**:
```bash
kubectl get pods -n aiops
kubectl exec -it deployment/aiops-agent -n aiops -- python -c "from aiops_agent.agent import AIOpsAgent; from aiops_agent.config import AgentConfig; agent = AIOpsAgent(AgentConfig()); print(agent.health_check())"
```

### Logs Verification

**Docker**:
```bash
docker logs --tail=50 aiops-agent
```

**Kubernetes**:
```bash
kubectl logs --tail=50 deployment/aiops-agent -n aiops
```

Look for successful startup messages:
```json
{"timestamp": "...", "level": "INFO", "logger": "aiops_agent.main", "message": "Starting AIOps Agent"}
{"timestamp": "...", "level": "INFO", "logger": "aiops_agent.agent", "message": "AIOps Agent initialized with config: aiops-agent"}
```

### Metrics Verification

The agent should be collecting metrics. Check logs for entries like:
```json
{"timestamp": "...", "level": "INFO", "logger": "aiops_agent.agent", "message": "Metrics exported: {...}"}
```

## Troubleshooting

### Image Pull Errors

If you see `ImagePullBackOff`:

1. Verify image exists:
   ```bash
   docker images | grep aiops-agent
   ```

2. Check image pull policy in deployment:
   ```yaml
   imagePullPolicy: IfNotPresent
   ```

3. Add image pull secret if using private registry:
   ```yaml
   spec:
     imagePullSecrets:
     - name: regcred
   ```

### Permission Errors

If you see permission denied errors:

1. Verify RBAC:
   ```bash
   kubectl get serviceaccount,role,rolebinding -n aiops
   ```

2. Check pod security context:
   ```bash
   kubectl get pod <pod-name> -n aiops -o yaml | grep -A 10 securityContext
   ```

### Network Policy Issues

If the agent can't send alerts:

1. Check network policies:
   ```bash
   kubectl get networkpolicy -n aiops
   ```

2. Temporarily remove network policy for testing:
   ```bash
   kubectl delete networkpolicy aiops-agent-network-policy -n aiops
   ```

3. Review DNS resolution:
   ```bash
   kubectl exec -it deployment/aiops-agent -n aiops -- nslookup google.com
   ```

## Next Steps

After successful installation:

1. Review [Configuration Guide](CONFIGURATION.md) for detailed configuration options
2. Check [Security Guide](SECURITY.md) for hardening recommendations
3. See [Operations Guide](OPERATIONS.md) for day-to-day management
4. Review [Monitoring Guide](MONITORING.md) for observability setup

## Support

For installation issues:
- Check the [Troubleshooting](../README.md#troubleshooting) section
- Review Kubernetes events: `kubectl get events -n aiops`
- Open an issue on GitHub with logs and error messages
