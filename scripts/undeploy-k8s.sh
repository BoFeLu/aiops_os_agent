#!/bin/bash
#
# Undeploy AIOps Agent from Kubernetes
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

echo -e "${YELLOW}Undeploying AIOps Agent from Kubernetes${NC}"
echo "Namespace: ${NAMESPACE}"
echo ""

read -p "Are you sure you want to delete all AIOps Agent resources? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 0
fi

# Delete in reverse order
echo -e "${YELLOW}Deleting HPA...${NC}"
${KUBECTL} delete -f k8s/hpa.yaml --ignore-not-found=true

echo -e "${YELLOW}Deleting PDB...${NC}"
${KUBECTL} delete -f k8s/pdb.yaml --ignore-not-found=true

echo -e "${YELLOW}Deleting Deployment...${NC}"
${KUBECTL} delete -f k8s/deployment.yaml --ignore-not-found=true

echo -e "${YELLOW}Deleting Service...${NC}"
${KUBECTL} delete -f k8s/service.yaml --ignore-not-found=true

echo -e "${YELLOW}Deleting Network Policy...${NC}"
${KUBECTL} delete -f k8s/network-policy.yaml --ignore-not-found=true

echo -e "${YELLOW}Deleting Secret...${NC}"
${KUBECTL} delete -f k8s/secret.yaml --ignore-not-found=true

echo -e "${YELLOW}Deleting ConfigMap...${NC}"
${KUBECTL} delete -f k8s/configmap.yaml --ignore-not-found=true

echo -e "${YELLOW}Deleting RBAC...${NC}"
${KUBECTL} delete -f k8s/rbac.yaml --ignore-not-found=true

read -p "Delete namespace '${NAMESPACE}'? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Deleting namespace...${NC}"
    ${KUBECTL} delete -f k8s/namespace.yaml --ignore-not-found=true
fi

echo ""
echo -e "${GREEN}✓ Undeployment complete!${NC}"
