#!/bin/bash
#
# Build and push Docker image for AIOps Agent
#

set -e

# Configuration
IMAGE_NAME="${IMAGE_NAME:-aiops-agent}"
IMAGE_TAG="${IMAGE_TAG:-1.0.0}"
REGISTRY="${REGISTRY:-}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Building AIOps Agent Docker Image${NC}"
echo "Image: ${IMAGE_NAME}:${IMAGE_TAG}"
echo ""

# Build the image
echo -e "${YELLOW}Building Docker image...${NC}"
docker build -t ${IMAGE_NAME}:${IMAGE_TAG} -t ${IMAGE_NAME}:latest .

echo -e "${GREEN}✓ Docker image built successfully${NC}"

# Tag for registry if specified
if [ -n "$REGISTRY" ]; then
    echo -e "${YELLOW}Tagging image for registry...${NC}"
    docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}
    docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${REGISTRY}/${IMAGE_NAME}:latest
    echo -e "${GREEN}✓ Image tagged for registry: ${REGISTRY}${NC}"
    
    # Push to registry
    read -p "Push to registry? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Pushing to registry...${NC}"
        docker push ${REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}
        docker push ${REGISTRY}/${IMAGE_NAME}:latest
        echo -e "${GREEN}✓ Images pushed successfully${NC}"
    fi
fi

echo ""
echo -e "${GREEN}Build complete!${NC}"
echo "Run locally with: docker run -it ${IMAGE_NAME}:${IMAGE_TAG}"
