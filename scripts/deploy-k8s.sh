#!/bin/bash
#
# Deploy AIOps Agent to Kubernetes
#

set -e

# Configuration
NAMESPACE="${NAMESPACE:-aiops}"
KUBECTL="${KUBECTL:-kubectl}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Deploying AIOps Agent to Kubernetes${NC}"
echo "Namespace: ${NAMESPACE}"
echo ""

# Check if kubectl is available
if ! command -v ${KUBECTL} &> /dev/null; then
    echo -e "${RED}Error: kubectl not found${NC}"
    exit 1
fi

# Create namespace
echo -e "${YELLOW}Creating namespace...${NC}"
${KUBECTL} apply -f k8s/namespace.yaml

# Apply RBAC
echo -e "${YELLOW}Applying RBAC configuration...${NC}"
${KUBECTL} apply -f k8s/rbac.yaml

# Apply ConfigMap
echo -e "${YELLOW}Applying ConfigMap...${NC}"
${KUBECTL} apply -f k8s/configmap.yaml

# Apply Secret (warn if using default)
echo -e "${YELLOW}Applying Secret...${NC}"
echo -e "${YELLOW}⚠ Warning: Update k8s/secret.yaml with your webhook URL before production deployment${NC}"
${KUBECTL} apply -f k8s/secret.yaml

# Apply Network Policy
echo -e "${YELLOW}Applying Network Policy...${NC}"
${KUBECTL} apply -f k8s/network-policy.yaml

# Apply Service
echo -e "${YELLOW}Applying Service...${NC}"
${KUBECTL} apply -f k8s/service.yaml

# Apply Deployment
echo -e "${YELLOW}Applying Deployment...${NC}"
${KUBECTL} apply -f k8s/deployment.yaml

# Apply PodDisruptionBudget
echo -e "${YELLOW}Applying PodDisruptionBudget...${NC}"
${KUBECTL} apply -f k8s/pdb.yaml

# Apply HPA (optional)
echo -e "${YELLOW}Applying HorizontalPodAutoscaler...${NC}"
${KUBECTL} apply -f k8s/hpa.yaml

echo ""
echo -e "${GREEN}✓ Deployment complete!${NC}"
echo ""
echo "Check deployment status:"
echo "  ${KUBECTL} get pods -n ${NAMESPACE}"
echo ""
echo "View logs:"
echo "  ${KUBECTL} logs -f deployment/aiops-agent -n ${NAMESPACE}"
echo ""
echo "Describe deployment:"
echo "  ${KUBECTL} describe deployment aiops-agent -n ${NAMESPACE}"
