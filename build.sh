#!/bin/bash

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Configuration
IMAGE_NAME="sensitive-lexicon"
IMAGE_TAG="${IMAGE_TAG:-latest}"
REGISTRY="${REGISTRY:-}"
FULL_IMAGE_NAME="${REGISTRY}${IMAGE_NAME}:${IMAGE_TAG}"

echo -e "${BLUE}Building Docker image: ${FULL_IMAGE_NAME}${NC}"
echo -e "${YELLOW}Platform: linux/amd64,linux/arm64${NC}"

# Build image for both platforms
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  --tag "$FULL_IMAGE_NAME" \
  --load \
  .

echo -e "${GREEN}Build complete: ${FULL_IMAGE_NAME}${NC}"
echo -e "${BLUE}Tagging as ${IMAGE_NAME}:latest${NC}"
docker tag "$FULL_IMAGE_NAME" "${IMAGE_NAME}:latest"

if [ -n "$REGISTRY" ]; then
  echo -e "${YELLOW}Pushing to registry...${NC}"
  docker push "$FULL_IMAGE_NAME"
  docker push "${IMAGE_NAME}:latest"
  echo -e "${GREEN}Push complete${NC}"
fi