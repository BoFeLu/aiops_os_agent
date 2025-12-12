#!/bin/bash
# AIOps Local Image Management - CORRECTED VERSION
# Author: Alberto (aiops_user)

set -euo pipefail
IFS=$'\n\t'

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

build_aiops_image() {
    log "Building AIOps Agent Docker image..."
    
    # Create corrected Dockerfile
    cat > /tmp/Dockerfile.aiops <<'EOF'
FROM python:3.11-alpine
LABEL maintainer="aiops_user"
LABEL version="dev"

# Install system dependencies
RUN apk add --no-cache curl wget jq procps

WORKDIR /app

# Create health check script
RUN echo '#!/bin/sh' > /app/health.sh && \
    echo 'echo "AIOps Agent Health Check: OK"' >> /app/health.sh && \
    echo 'echo "Timestamp: $(date)"' >> /app/health.sh && \
    echo 'echo "Hostname: $(hostname)"' >> /app/health.sh && \
    chmod +x /app/health.sh

# Create main agent script
RUN echo 'import time' > /app/agent.py && \
    echo 'import os' >> /app/agent.py && \
    echo 'import json' >> /app/agent.py && \
    echo 'print("=== AIOps Agent Starting ===")' >> /app/agent.py && \
    echo 'print("Environment:", os.environ.get("ENVIRONMENT", "unknown"))' >> /app/agent.py && \
    echo 'print("Pod Name:", os.environ.get("POD_NAME", "unknown"))' >> /app/agent.py && \
    echo 'counter = 0' >> /app/agent.py && \
    echo 'while True:' >> /app/agent.py && \
    echo '    counter += 1' >> /app/agent.py && \
    echo '    timestamp = time.strftime("%Y-%m-%d %H:%M:%S")' >> /app/agent.py && \
    echo '    print(f"[{timestamp}] AIOps Agent Heartbeat #{counter}")' >> /app/agent.py && \
    echo '    if counter % 10 == 0:' >> /app/agent.py && \
    echo '        with open("/data/heartbeat.log", "a") as f:' >> /app/agent.py && \
    echo '            f.write(f"{timestamp} - Heartbeat #{counter}\\n")' >> /app/agent.py && \
    echo '        print(f"[{timestamp}] Wrote to persistent storage")' >> /app/agent.py && \
    echo '    time.sleep(30)' >> /app/agent.py

EXPOSE 8080

# Fixed HEALTHCHECK syntax
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD /app/health.sh

CMD ["python", "/app/agent.py"]
EOF
    
    log "Setting Minikube Docker environment..."
    eval $(minikube docker-env)
    
    log "Building image 'aiops-agent:dev'..."
    if docker build -f /tmp/Dockerfile.aiops -t aiops-agent:dev .; then
        success "AIOps Agent image built successfully"
        docker images | grep aiops-agent || true
    else
        error "Failed to build AIOps Agent image"
        exit 1
    fi
    
    rm -f /tmp/Dockerfile.aiops
    eval $(minikube docker-env -u)
}

create_aiops_deployment() {
    log "Creating AIOps Agent deployment manifest..."
    
    local deployment_file="./manifests/aiops-agent-deployment.yaml"
    
    cat > "$deployment_file" <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: aiops-agent
  namespace: aiops
  labels:
    app: aiops-agent
    version: dev
spec:
  replicas: 1
  selector:
    matchLabels:
      app: aiops-agent
  template:
    metadata:
      labels:
        app: aiops-agent
        component: aiops
    spec:
      serviceAccountName: aiops-agent
      securityContext:
        runAsNonRoot: true
        runAsUser: 1000
        runAsGroup: 1000
        fsGroup: 1000
      containers:
      - name: aiops-agent
        image: aiops-agent:dev
        imagePullPolicy: IfNotPresent
        ports:
        - containerPort: 8080
          name: http
        resources:
          requests:
            memory: "128Mi"
            cpu: "100m"
          limits:
            memory: "256Mi"
            cpu: "200m"
        livenessProbe:
          exec:
            command:
            - /app/health.sh
          initialDelaySeconds: 10
          periodSeconds: 30
        readinessProbe:
          exec:
            command:
            - /app/health.sh
          initialDelaySeconds: 5
          periodSeconds: 10
        volumeMounts:
        - name: aiops-storage
          mountPath: /data
        env:
        - name: ENVIRONMENT
          value: "development"
        - name: POD_NAME
          valueFrom:
            fieldRef:
              fieldPath: metadata.name
      volumes:
      - name: aiops-storage
        persistentVolumeClaim:
          claimName: aiops-data

---
apiVersion: v1
kind: Service
metadata:
  name: aiops-agent-service
  namespace: aiops
  labels:
    app: aiops-agent
spec:
  type: ClusterIP
  ports:
  - port: 8080
    targetPort: 8080
    name: http
  selector:
    app: aiops-agent
EOF
    
    success "Deployment manifest created: $deployment_file"
}

deploy_agent() {
    log "Deploying AIOps Agent..."
    
    if [ ! -f "./manifests/aiops-agent-deployment.yaml" ]; then
        create_aiops_deployment
    fi
    
    minikube kubectl -- apply -f ./manifests/aiops-agent-deployment.yaml
    
    log "Waiting for deployment..."
    minikube kubectl -- wait --for=condition=available deployment/aiops-agent -n aiops --timeout=120s
    
    log "Deployment status:"
    minikube kubectl -- get pods,svc -n aiops
    
    success "AIOps Agent deployed successfully"
}

show_logs() {
    log "Recent AIOps Agent logs:"
    minikube kubectl -- logs -n aiops -l app=aiops-agent --tail=15
}

main() {
    case "${1:-all}" in
        "build")
            build_aiops_image
            ;;
        "deploy")
            create_aiops_deployment
            deploy_agent
            ;;
        "logs")
            show_logs
            ;;
        "status")
            minikube kubectl -- get pods,svc -n aiops
            ;;
        "all")
            build_aiops_image
            create_aiops_deployment
            deploy_agent
            show_logs
            ;;
        *)
            echo "Usage: $0 {build|deploy|logs|status|all}"
            exit 1
            ;;
    esac
}

main "$@"
