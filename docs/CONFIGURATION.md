# Configuration Reference

Complete configuration reference for the AIOps Agent.

## Overview

The AIOps Agent can be configured through:
1. Environment variables
2. ConfigMaps (Kubernetes)
3. Secrets (for sensitive data)
4. Command-line arguments (future enhancement)

## Environment Variables

### Agent Identification

#### AGENT_NAME
- **Description**: Unique identifier for the agent instance
- **Type**: String
- **Default**: `aiops-agent`
- **Example**: `aiops-agent-production-01`
- **Required**: No

#### ENVIRONMENT
- **Description**: Deployment environment identifier
- **Type**: String
- **Default**: `production`
- **Allowed Values**: `development`, `staging`, `production`
- **Example**: `production`
- **Required**: No

### Monitoring Configuration

#### COLLECTION_INTERVAL
- **Description**: Interval between metric collections (in seconds)
- **Type**: Integer
- **Default**: `60`
- **Range**: `10` - `3600`
- **Example**: `30`
- **Required**: No
- **Notes**: Lower values increase CPU usage and metrics volume

#### METRICS_EXPORT_ENABLED
- **Description**: Enable/disable metrics export
- **Type**: Boolean
- **Default**: `true`
- **Allowed Values**: `true`, `false`
- **Required**: No

### Anomaly Detection

#### ANOMALY_DETECTION_ENABLED
- **Description**: Enable/disable anomaly detection
- **Type**: Boolean
- **Default**: `true`
- **Allowed Values**: `true`, `false`
- **Required**: No

#### CPU_THRESHOLD
- **Description**: CPU usage threshold for anomaly detection (percentage)
- **Type**: Float
- **Default**: `80.0`
- **Range**: `0.0` - `100.0`
- **Example**: `85.0`
- **Required**: No

#### MEMORY_THRESHOLD
- **Description**: Memory usage threshold for anomaly detection (percentage)
- **Type**: Float
- **Default**: `85.0`
- **Range**: `0.0` - `100.0`
- **Example**: `90.0`
- **Required**: No

#### DISK_THRESHOLD
- **Description**: Disk usage threshold for anomaly detection (percentage)
- **Type**: Float
- **Default**: `90.0`
- **Range**: `0.0` - `100.0`
- **Example**: `95.0`
- **Required**: No

### Alerting Configuration

#### ALERT_ENABLED
- **Description**: Enable/disable alert sending
- **Type**: Boolean
- **Default**: `true`
- **Allowed Values**: `true`, `false`
- **Required**: No

#### ALERT_WEBHOOK_URL
- **Description**: Webhook URL for sending alerts
- **Type**: String (URL)
- **Default**: `""` (empty)
- **Example**: `https://hooks.slack.com/services/YOUR/WEBHOOK/URL`
- **Required**: No (but recommended for production)
- **Security**: Should be stored in Kubernetes Secret

#### ALERT_WEBHOOK_TIMEOUT
- **Description**: Timeout for webhook HTTP requests (in seconds)
- **Type**: Integer
- **Default**: `10`
- **Range**: `1` - `60`
- **Example**: `15`
- **Required**: No

### Logging Configuration

#### LOG_LEVEL
- **Description**: Logging level
- **Type**: String
- **Default**: `INFO`
- **Allowed Values**: `DEBUG`, `INFO`, `WARNING`, `ERROR`, `CRITICAL`
- **Example**: `DEBUG`
- **Required**: No

#### LOG_FORMAT
- **Description**: Log output format
- **Type**: String
- **Default**: `json`
- **Allowed Values**: `json`, `text`
- **Example**: `json`
- **Required**: No
- **Notes**: JSON format is recommended for production (easier parsing)

## Configuration Examples

### Development Environment

```bash
# Docker
docker run -d \
  -e AGENT_NAME=dev-agent \
  -e ENVIRONMENT=development \
  -e COLLECTION_INTERVAL=30 \
  -e LOG_LEVEL=DEBUG \
  -e LOG_FORMAT=text \
  -e ALERT_ENABLED=false \
  aiops-agent:1.0.0
```

### Production Environment (Kubernetes)

**ConfigMap** (`k8s/configmap.yaml`):
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: aiops-agent-config
  namespace: aiops
data:
  AGENT_NAME: "aiops-agent-prod"
  ENVIRONMENT: "production"
  COLLECTION_INTERVAL: "60"
  LOG_LEVEL: "INFO"
  LOG_FORMAT: "json"
  METRICS_EXPORT_ENABLED: "true"
  ANOMALY_DETECTION_ENABLED: "true"
  CPU_THRESHOLD: "80.0"
  MEMORY_THRESHOLD: "85.0"
  DISK_THRESHOLD: "90.0"
  ALERT_ENABLED: "true"
```

**Secret** (`k8s/secret.yaml`):
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: aiops-agent-secrets
  namespace: aiops
type: Opaque
stringData:
  ALERT_WEBHOOK_URL: "https://your-webhook-url.example.com"
```

### High-Frequency Monitoring

For systems requiring more frequent monitoring:

```yaml
data:
  COLLECTION_INTERVAL: "15"  # 15 seconds
  CPU_THRESHOLD: "75.0"       # Lower thresholds
  MEMORY_THRESHOLD: "80.0"
  DISK_THRESHOLD: "85.0"
```

**Note**: Higher frequency increases resource usage.

### Conservative Thresholds

For critical systems where you want early warnings:

```yaml
data:
  CPU_THRESHOLD: "70.0"
  MEMORY_THRESHOLD: "75.0"
  DISK_THRESHOLD: "80.0"
```

## Applying Configuration Changes

### Docker

Restart the container with new environment variables:

```bash
docker stop aiops-agent
docker rm aiops-agent
docker run -d \
  --name aiops-agent \
  -e AGENT_NAME=new-name \
  -e LOG_LEVEL=DEBUG \
  aiops-agent:1.0.0
```

### Kubernetes

#### Method 1: Edit ConfigMap

```bash
# Edit the configmap
kubectl edit configmap aiops-agent-config -n aiops

# Restart deployment to pick up changes
kubectl rollout restart deployment/aiops-agent -n aiops

# Monitor rollout
kubectl rollout status deployment/aiops-agent -n aiops
```

#### Method 2: Apply Updated YAML

```bash
# Update k8s/configmap.yaml
kubectl apply -f k8s/configmap.yaml

# Restart deployment
kubectl rollout restart deployment/aiops-agent -n aiops
```

#### Update Secrets

```bash
# Edit secret
kubectl edit secret aiops-agent-secrets -n aiops

# Or apply updated secret file
kubectl apply -f k8s/secret.yaml

# Restart deployment
kubectl rollout restart deployment/aiops-agent -n aiops
```

## Validation

### Verify Configuration Loading

Check the logs to see what configuration was loaded:

**Docker**:
```bash
docker logs aiops-agent 2>&1 | grep -i "initialized\|config"
```

**Kubernetes**:
```bash
kubectl logs deployment/aiops-agent -n aiops | grep -i "initialized\|config"
```

### Test Configuration

You can test configuration changes without full deployment:

```bash
# Create a test container
docker run -it --rm \
  -e AGENT_NAME=test \
  -e LOG_LEVEL=DEBUG \
  aiops-agent:1.0.0 \
  python -c "from aiops_agent.config import AgentConfig; c = AgentConfig(); print(c.to_dict())"
```

## Best Practices

### Security

1. **Never commit secrets** to version control
2. **Use Kubernetes Secrets** for sensitive data
3. **Rotate webhook URLs** regularly
4. **Limit secret access** with RBAC

### Performance

1. **Adjust collection interval** based on system load
2. **Monitor agent resource usage** and adjust limits
3. **Use appropriate thresholds** for your workload
4. **Enable metrics export** only when needed

### Reliability

1. **Set conservative thresholds** to avoid alert fatigue
2. **Test configuration changes** in non-production first
3. **Use ConfigMaps** for easy updates without rebuilds
4. **Document custom configurations** for your environment

## Troubleshooting

### Configuration Not Applied

1. Check ConfigMap/Secret exists:
   ```bash
   kubectl get configmap aiops-agent-config -n aiops -o yaml
   kubectl get secret aiops-agent-secrets -n aiops -o yaml
   ```

2. Verify deployment references correct ConfigMap/Secret:
   ```bash
   kubectl get deployment aiops-agent -n aiops -o yaml | grep -A 5 configMapRef
   ```

3. Restart deployment:
   ```bash
   kubectl rollout restart deployment/aiops-agent -n aiops
   ```

### Invalid Configuration Values

Check logs for validation errors:
```bash
kubectl logs deployment/aiops-agent -n aiops | grep -i error
```

### Environment Variables Not Set

For Docker, verify variables are passed:
```bash
docker inspect aiops-agent | grep -A 20 Env
```

For Kubernetes, check pod environment:
```bash
kubectl exec deployment/aiops-agent -n aiops -- env | grep AGENT
```

## Advanced Configuration

### Custom Alerting Endpoints

For multiple webhook URLs (requires code modification):

1. Extend the `AlertManager` class
2. Add support for multiple webhooks
3. Configure via additional environment variables

### Custom Metrics

To add custom metrics:

1. Extend the `MetricsCollector` class
2. Add new metric collection methods
3. Update anomaly detector if needed

### Integration with External Systems

Configure integration with:
- Prometheus (for metrics scraping)
- Grafana (for visualization)
- PagerDuty (for incident management)
- ServiceNow (for ticket creation)

## See Also

- [Installation Guide](INSTALLATION.md)
- [Security Guide](SECURITY.md)
- [Operations Guide](OPERATIONS.md)
