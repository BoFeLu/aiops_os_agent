# Security Guide

Security best practices and hardening guide for the AIOps Agent.

## Overview

The AIOps Agent is built with security-first principles, incorporating defense-in-depth strategies at multiple layers. This guide covers security features, configurations, and best practices.

## Security Features

### Container Security

#### Non-Root User Execution
- **UID/GID**: 1001:1001
- **User**: `aiops` (non-privileged)
- **Implementation**: Defined in Dockerfile and security contexts

```dockerfile
RUN groupadd -r aiops && useradd -r -g aiops -u 1001 aiops
USER aiops
```

#### Read-Only Root Filesystem
- Root filesystem mounted as read-only
- Writable directories: `/tmp`, `/app/logs`, `/app/data` (using emptyDir volumes)

```yaml
securityContext:
  readOnlyRootFilesystem: true
```

#### Minimal Capabilities
- All Linux capabilities dropped by default
- Only essential capabilities added when needed

```yaml
securityContext:
  capabilities:
    drop:
      - ALL
    add:
      - NET_BIND_SERVICE
```

#### No Privilege Escalation
- Prevents privilege escalation attacks

```yaml
securityContext:
  allowPrivilegeEscalation: false
```

### Kubernetes Security

#### RBAC (Role-Based Access Control)

Minimal permissions for the service account:

```yaml
rules:
  - apiGroups: [""]
    resources: ["pods", "services", "configmaps"]
    verbs: ["get", "list", "watch"]
  - apiGroups: [""]
    resources: ["events"]
    verbs: ["create", "patch"]
```

**Review**: Regularly audit RBAC permissions
```bash
kubectl describe role aiops-agent -n aiops
```

#### Network Policies

Restricts network traffic to only what's necessary:

**Ingress**:
- Allow from monitoring namespace (Prometheus)
- Port 8080 only

**Egress**:
- DNS queries (UDP 53)
- HTTPS (TCP 443) for webhooks
- HTTP (TCP 80) if needed

```yaml
policyTypes:
- Ingress
- Egress
```

**Review network policies**:
```bash
kubectl describe networkpolicy aiops-agent-network-policy -n aiops
```

#### Pod Security Standards

Implements restricted pod security:

```yaml
securityContext:
  runAsNonRoot: true
  runAsUser: 1001
  runAsGroup: 1001
  fsGroup: 1001
  seccompProfile:
    type: RuntimeDefault
```

#### Secrets Management

Sensitive data stored in Kubernetes Secrets:

```yaml
env:
- name: ALERT_WEBHOOK_URL
  valueFrom:
    secretKeyRef:
      name: aiops-agent-secrets
      key: ALERT_WEBHOOK_URL
```

## Security Hardening

### 1. Image Security

#### Scan for Vulnerabilities

```bash
# Using Trivy
trivy image aiops-agent:1.0.0

# Using Docker Scan
docker scan aiops-agent:1.0.0

# Using Clair
clairctl analyze aiops-agent:1.0.0
```

#### Keep Base Images Updated

```bash
# Rebuild with latest base image
docker build --no-cache --pull -t aiops-agent:1.0.0 .
```

#### Use Minimal Base Images

Current: `python:3.11-slim`
- Smaller attack surface
- Fewer vulnerabilities
- Faster deployment

### 2. Runtime Security

#### Pod Security Policies (PSP) / Pod Security Admission

For Kubernetes 1.25+, use Pod Security Admission:

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: aiops
  labels:
    pod-security.kubernetes.io/enforce: restricted
    pod-security.kubernetes.io/audit: restricted
    pod-security.kubernetes.io/warn: restricted
```

#### AppArmor / SELinux

Add AppArmor profile annotation:

```yaml
metadata:
  annotations:
    container.apparmor.security.beta.kubernetes.io/aiops-agent: runtime/default
```

#### Seccomp Profiles

Already configured in deployment:

```yaml
securityContext:
  seccompProfile:
    type: RuntimeDefault
```

### 3. Network Security

#### TLS/SSL for Webhooks

Ensure webhook URLs use HTTPS:

```yaml
stringData:
  ALERT_WEBHOOK_URL: "https://secure-webhook.example.com"  # ✓
  # NOT: "http://insecure-webhook.example.com"  # ✗
```

#### Network Segmentation

Isolate the AIOps namespace:

```bash
# Create dedicated network policies
kubectl apply -f k8s/network-policy.yaml

# Verify isolation
kubectl exec -it deployment/aiops-agent -n aiops -- ping google.com
```

#### Service Mesh Integration

For advanced security, integrate with service mesh:

```yaml
annotations:
  sidecar.istio.io/inject: "true"
```

### 4. Secrets Management

#### External Secrets Operator

For production, use external secrets management:

```yaml
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: aiops-agent-secrets
  namespace: aiops
spec:
  secretStoreRef:
    name: vault-backend
  target:
    name: aiops-agent-secrets
  data:
  - secretKey: ALERT_WEBHOOK_URL
    remoteRef:
      key: /aiops/webhook-url
```

#### Sealed Secrets

Encrypt secrets in Git:

```bash
# Create sealed secret
kubeseal --format=yaml < k8s/secret.yaml > k8s/sealed-secret.yaml

# Apply sealed secret
kubectl apply -f k8s/sealed-secret.yaml
```

#### Rotate Secrets Regularly

```bash
# Update webhook URL
kubectl create secret generic aiops-agent-secrets \
  --from-literal=ALERT_WEBHOOK_URL=new-url \
  --dry-run=client -o yaml | kubectl apply -f -

# Restart deployment
kubectl rollout restart deployment/aiops-agent -n aiops
```

### 5. Access Control

#### Limit Cluster Access

```bash
# Create read-only kubeconfig for monitoring
kubectl create clusterrolebinding aiops-viewer \
  --clusterrole=view \
  --serviceaccount=aiops:aiops-agent
```

#### Audit Logging

Enable Kubernetes audit logging for the namespace:

```yaml
apiVersion: audit.k8s.io/v1
kind: Policy
rules:
- level: Metadata
  namespaces: ["aiops"]
```

### 6. Resource Limits

Prevent resource exhaustion attacks:

```yaml
resources:
  requests:
    cpu: 100m
    memory: 128Mi
  limits:
    cpu: 500m
    memory: 512Mi
```

**Monitor resource usage**:
```bash
kubectl top pod -n aiops
```

## Security Monitoring

### 1. Audit Logs

Monitor for suspicious activities:

```bash
# View audit logs
kubectl logs -n kube-system $(kubectl get pod -n kube-system -l component=kube-apiserver -o name) | grep aiops

# Watch for authentication failures
kubectl get events -n aiops --watch
```

### 2. Runtime Security Monitoring

Use tools like Falco:

```bash
# Install Falco
helm repo add falcosecurity https://falcosecurity.github.io/charts
helm install falco falcosecurity/falco

# Monitor AIOps namespace
kubectl logs -f -n falco $(kubectl get pod -n falco -l app=falco -o name)
```

### 3. Vulnerability Scanning

Continuous scanning:

```bash
# Schedule periodic scans
kubectl create cronjob scan-aiops-agent \
  --image=aquasec/trivy \
  --schedule="0 2 * * *" \
  -- image aiops-agent:1.0.0
```

## Compliance

### CIS Kubernetes Benchmark

Check compliance:

```bash
# Using kube-bench
kubectl apply -f https://raw.githubusercontent.com/aquasecurity/kube-bench/main/job.yaml
kubectl logs job/kube-bench
```

### Security Checklists

#### Pre-Deployment

- [ ] Scan container image for vulnerabilities
- [ ] Review and update RBAC permissions
- [ ] Verify network policies are in place
- [ ] Ensure secrets are not in ConfigMaps
- [ ] Validate security contexts
- [ ] Test with least privilege
- [ ] Enable audit logging
- [ ] Configure resource limits

#### Post-Deployment

- [ ] Verify pod runs as non-root
- [ ] Check read-only filesystem is enforced
- [ ] Validate network policies are active
- [ ] Test webhook connectivity over HTTPS
- [ ] Monitor for security events
- [ ] Review audit logs
- [ ] Scan running containers

#### Ongoing

- [ ] Weekly vulnerability scans
- [ ] Monthly RBAC audits
- [ ] Quarterly security reviews
- [ ] Regular secret rotation
- [ ] Base image updates
- [ ] Dependency updates

## Incident Response

### Security Incident Procedure

1. **Detect**: Monitor logs and alerts
2. **Isolate**: Apply restrictive network policy
3. **Investigate**: Review logs and metrics
4. **Remediate**: Patch vulnerabilities
5. **Document**: Record incident details

### Isolation Procedure

```bash
# Apply strict network policy
kubectl apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: isolate-aiops-agent
  namespace: aiops
spec:
  podSelector:
    matchLabels:
      app: aiops-agent
  policyTypes:
  - Ingress
  - Egress
  # Deny all traffic
EOF

# Scale down deployment
kubectl scale deployment aiops-agent --replicas=0 -n aiops
```

### Evidence Collection

```bash
# Collect pod logs
kubectl logs deployment/aiops-agent -n aiops --all-containers > aiops-logs.txt

# Describe pod
kubectl describe pod -n aiops -l app=aiops-agent > aiops-pod-desc.txt

# Get events
kubectl get events -n aiops --sort-by='.lastTimestamp' > aiops-events.txt

# Export configuration
kubectl get deployment,configmap,secret -n aiops -o yaml > aiops-config.yaml
```

## Security Best Practices

### Development

1. **Never commit secrets** to version control
2. **Use .gitignore** for sensitive files
3. **Scan dependencies** for vulnerabilities
4. **Keep dependencies updated**
5. **Follow secure coding practices**
6. **Code review** security-related changes

### Deployment

1. **Use private registries** for production images
2. **Sign container images** with Docker Content Trust
3. **Implement image pull policies**
4. **Use specific image tags** (not `latest`)
5. **Enable pod security policies**
6. **Configure resource quotas**

### Operations

1. **Monitor security events** continuously
2. **Rotate credentials** regularly
3. **Audit access logs** frequently
4. **Update images** promptly
5. **Test disaster recovery** procedures
6. **Maintain security documentation**

## Security Tools

### Recommended Tools

- **Trivy**: Vulnerability scanning
- **Falco**: Runtime security monitoring
- **OPA/Gatekeeper**: Policy enforcement
- **cert-manager**: Certificate management
- **Vault**: Secrets management
- **Istio**: Service mesh security

### Integration Examples

#### Trivy Scanning

```bash
# Add to CI/CD pipeline
trivy image --severity HIGH,CRITICAL aiops-agent:1.0.0
```

#### OPA Gatekeeper

```yaml
apiVersion: constraints.gatekeeper.sh/v1beta1
kind: K8sRequiredLabels
metadata:
  name: require-security-labels
spec:
  match:
    kinds:
      - apiGroups: [""]
        kinds: ["Pod"]
    namespaces: ["aiops"]
  parameters:
    labels: ["app", "version", "environment"]
```

## References

- [Kubernetes Security Best Practices](https://kubernetes.io/docs/concepts/security/overview/)
- [CIS Kubernetes Benchmark](https://www.cisecurity.org/benchmark/kubernetes)
- [NIST Container Security Guide](https://www.nist.gov/publications/application-container-security-guide)
- [OWASP Docker Security Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Docker_Security_Cheat_Sheet.html)

## Support

For security issues:
- Report via GitHub Security Advisories
- Email: security@example.com (configure for your organization)
- Follow responsible disclosure practices
