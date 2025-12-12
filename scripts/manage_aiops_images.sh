#!/bin/bash
# AIOps Local Image Management
# Author: Alberto (aiops_user)
# Purpose: Manage local Docker images for Minikube deployment

set -euo pipefail
IFS=$'\n\t'

# Color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Build AIOps Agent image locally
build_aiops_image() {
    log "Building AIOps Agent Docker image..."
    
    # Create a simple Dockerfile for testing
    local dockerfile_content=$(cat <<EOF
FROM python:3.11-alpine
LABEL maintainer="aiops_user"
LABEL version="dev"
LABEL purpose="aiops-agent-development"

# Install basic dependencies
RUN apk add --no-cache curl wget jq

# Create application directory
WORKDIR /app

# Create a simple health check script
RUN echo '#!/bin/sh' > /app/health.sh && \\
    echo 'echo "AIOps Agent Health Check: OK"' >> /app/health.sh && \\
    echo 'echo "Timestamp: \$(date)"' >> /app/health.sh && \\
    echo 'echo "Hostname: \$(hostname)"' >> /app/health.sh && \\
    chmod +x /app/health.sh

# Create main application script
RUN echo '#!/bin/sh' > /app/main.py && \\
    echo 'import time' >> /app/main.py && \\
    echo 'import os' >> /app/main.py && \\
    echo 'import json' >> /app/main.py && \\
    echo 'print("AIOps Agent starting...")' >> /app/main.py && \\
    echo 'while True:' >> /app/main.py && \\
    echo '    print(f"AIOps Agent heartbeat: {time.strftime(\"%Y-%m-%d %H:%M:%S\")}")' >> /app/main.py && \\
    echo '    time.sleep(30)' >> /app/main.py

# Expose port for health checks
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \\
    CMD /app/health.sh || exit 1

# Default command
CMD ["python", "/app/main.py"]
EOF
)
    
    # Write Dockerfile
    echo "$dockerfile_content" > /tmp/Dockerfile.aiops
    
    # Build using Minikube's Docker environment
    log "Setting Minikube Docker environment..."
    eval $(minikube docker-env)
    
    # Build the image
    docker build -f /tmp/Dockerfile.aiops -t aiops-agent:dev .
    
    # Verify image was built
    if docker images | grep -q "aiops-agent.*dev"; then
        success "AIOps Agent image built successfully"
        docker images | grep aiops-agent
    else
        error "Failed to build AIOps Agent image"
        exit 1
    fi
    
    # Clean up temporary Dockerfile
    rm -f /tmp/Dockerfile.aiops
}

# Load image to Minikube
load_image_to_minikube() {
    log "Loading image to Minikube..."
    
    # The image should already be in Minikube's Docker daemon
    # since we built it there, but let's verify
    eval $(minikube docker-env)
    
    if docker images | grep -q "aiops-agent.*dev"; then
        success "AIOps Agent image is available in Minikube"
    else
        error "AIOps Agent image not found in Minikube"
        exit 1
    fi
    
    # Return to host Docker environment
    eval $(minikube docker-env -u)
}

# Create deployment manifest for AIOps Agent
create_aiops_deployment() {
    log "Creating AIOps Agent deployment manifest..."
    
    local deployment_file="/home/claude/aiops-agent-deployment.yaml"
    
    cat > "$deployment_file" <<EOF
# AIOps Agent Deployment - Hardened Configuration
apiVersion: apps/v1
kind: Deployment
metadata:
  name: aiops-agent
  namespace: aiops
  labels:
    app: aiops-agent
    version: dev
    component: ai-operations
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
        security.level: restricted
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
          protocol: TCP
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        livenessProbe:
          exec:
            command:
            - /app/health.sh
          initialDelaySeconds: 10
          periodSeconds: 30
          timeoutSeconds: 5
          failureThreshold: 3
        readinessProbe:
          exec:
            command:
            - /app/health.sh
          initialDelaySeconds: 5
          periodSeconds: 10
          timeoutSeconds: 3
          failureThreshold: 2
        volumeMounts:
        - name: aiops-storage
          mountPath: /data
        env:
        - name: ENVIRONMENT
          value: "development"
        - name: NAMESPACE
          valueFrom:
            fieldRef:
              fieldPath: metadata.namespace
        - name: POD_NAME
          valueFrom:
            fieldRef:
              fieldPath: metadata.name
      volumes:
      - name: aiops-storage
        persistentVolumeClaim:
          claimName: aiops-data
      restartPolicy: Always

---
# Service for AIOps Agent
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
    protocol: TCP
    name: http
  selector:
    app: aiops-agent

---
# ConfigMap for AIOps Agent Configuration
apiVersion: v1
kind: ConfigMap
metadata:
  name: aiops-agent-config
  namespace: aiops
  labels:
    app: aiops-agent
data:
  config.yaml: |
    agent:
      name: "aiops-agent"
      environment: "development"
      log_level: "info"
    monitoring:
      enabled: true
      interval: "30s"
    storage:
      path: "/data"
      retention: "7d"
EOF
    
    success "AIOps Agent deployment manifest created: $deployment_file"
}

# Test deployment
test_deployment() {
    log "Testing AIOps Agent deployment..."
    
    # Apply the deployment
    kubectl apply -f /home/claude/aiops-agent-deployment.yaml
    
    # Wait for deployment to be ready
    log "Waiting for deployment to be ready..."
    kubectl wait --for=condition=available deployment/aiops-agent -n aiops --timeout=120s
    
    # Check pod status
    log "Checking pod status..."
    kubectl get pods -n aiops -l app=aiops-agent
    
    # Test service connectivity
    log "Testing service connectivity..."
    kubectl run test-connectivity --image=curlimages/curl:latest --rm -i --restart=Never -n aiops -- \
        curl -s http://aiops-agent-service:8080/ || warning "Service not responding (expected for this test image)"
    
    # Show logs
    log "Checking application logs..."
    timeout 10 kubectl logs -n aiops -l app=aiops-agent --tail=5 || true
    
    success "AIOps Agent deployment tested"
}

# List all images and cleanup
manage_images() {
    log "Managing Docker images..."
    
    # Set Minikube Docker environment
    eval $(minikube docker-env)
    
    log "Images available in Minikube:"
    docker images | grep -E "(aiops|alpine|python)"
    
    # Return to host environment
    eval $(minikube docker-env -u)
    
    log "Host Docker images:"
    docker images | grep -E "(aiops|alpine|python)" || echo "No matching images on host"
}

# Main function
main() {
    case "${1:-all}" in
        "build")
            build_aiops_image
            ;;
        "load")
            load_image_to_minikube
            ;;
        "deploy")
            create_aiops_deployment
            test_deployment
            ;;
        "manage")
            manage_images
            ;;
        "all")
            build_aiops_image
            load_image_to_minikube
            create_aiops_deployment
            ;;
        *)
            echo "Usage: $0 {build|load|deploy|manage|all}"
            echo "  build  - Build AIOps Agent image"
            echo "  load   - Load image to Minikube"
            echo "  deploy - Create and test deployment"
            echo "  manage - Show image status"
            echo "  all    - Run build, load, and create deployment"
            exit 1
            ;;
    esac
}

# Execute
main "$@"
