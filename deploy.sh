#!/bin/bash

# One-Click Docker Deploy Script for Uptime Kuma
# This script sets up and deploys Uptime Kuma using Docker Compose

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
PROJECT_NAME="uptime-kuma"
PORT="${PORT:-3001}"
DATA_DIR="./data"

echo -e "${GREEN}🚀 Uptime Kuma - One-Click Docker Deploy${NC}"
echo "================================================"
echo ""

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker is not installed. Please install Docker first.${NC}"
    echo "   Visit: https://docs.docker.com/get-docker/"
    exit 1
fi

# Check if Docker Compose is available (v2 uses 'docker compose', v1 uses 'docker-compose')
if docker compose version &> /dev/null; then
    COMPOSE_CMD="docker compose"
elif command -v docker-compose &> /dev/null; then
    COMPOSE_CMD="docker-compose"
else
    echo -e "${RED}❌ Docker Compose is not available.${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Docker found${NC}"

# Check if Docker daemon is running
if ! docker info &> /dev/null; then
    echo -e "${RED}❌ Docker daemon is not running. Please start Docker.${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Docker daemon is running${NC}"

# Create data directory if it doesn't exist
if [ ! -d "$DATA_DIR" ]; then
    echo -e "${YELLOW}📁 Creating data directory...${NC}"
    mkdir -p "$DATA_DIR"
    chmod 755 "$DATA_DIR"
    echo -e "${GREEN}✅ Data directory created${NC}"
else
    echo -e "${GREEN}✅ Data directory exists${NC}"
fi

# Create or update compose.yaml
echo -e "${YELLOW}📝 Setting up docker-compose configuration...${NC}"
cat > compose.yaml << EOF
services:
  uptime-kuma:
    image: louislam/uptime-kuma:2
    container_name: ${PROJECT_NAME}
    restart: unless-stopped
    volumes:
      - ${DATA_DIR}:/app/data
    ports:
      - "${PORT}:3001"
    environment:
      - UPTIME_KUMA_PORT=3001
EOF

echo -e "${GREEN}✅ Docker Compose configuration ready${NC}"

# Check if container is already running
if docker ps -a --format '{{.Names}}' | grep -q "^${PROJECT_NAME}$"; then
    echo -e "${YELLOW}⚠️  Container '${PROJECT_NAME}' already exists${NC}"
    read -p "Do you want to stop and remove the existing container? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}🛑 Stopping existing container...${NC}"
        $COMPOSE_CMD down 2>/dev/null || docker stop ${PROJECT_NAME} 2>/dev/null || true
        docker rm ${PROJECT_NAME} 2>/dev/null || true
        echo -e "${GREEN}✅ Existing container removed${NC}"
    else
        echo -e "${YELLOW}⚠️  Keeping existing container. Use 'docker start ${PROJECT_NAME}' to start it.${NC}"
        exit 0
    fi
fi

# Pull the latest image
echo -e "${YELLOW}📥 Pulling latest Uptime Kuma image...${NC}"
docker pull louislam/uptime-kuma:2 || echo -e "${YELLOW}⚠️  Failed to pull image, will use local if available${NC}"

# Start the container
echo -e "${YELLOW}🚀 Starting Uptime Kuma container...${NC}"
$COMPOSE_CMD up -d

# Wait a moment for container to start
sleep 2

# Check if container is running
if docker ps --format '{{.Names}}' | grep -q "^${PROJECT_NAME}$"; then
    echo ""
    echo -e "${GREEN}✅ Uptime Kuma is now running!${NC}"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "${GREEN}📊 Access your dashboard:${NC}"
    echo -e "   Local:   ${GREEN}http://localhost:${PORT}${NC}"
    echo -e "   Network: ${GREEN}http://$(hostname -I | awk '{print $1}'):${PORT}${NC}"
    echo ""
    echo -e "${YELLOW}💾 Data is stored in:${NC} $(pwd)/${DATA_DIR}"
    echo ""
    echo -e "${YELLOW}📋 Useful commands:${NC}"
    echo "   View logs:    docker logs -f ${PROJECT_NAME}"
    echo "   Stop:         docker stop ${PROJECT_NAME}"
    echo "   Start:        docker start ${PROJECT_NAME}"
    echo "   Restart:      docker restart ${PROJECT_NAME}"
    echo "   Remove:       docker rm -f ${PROJECT_NAME}"
    echo "   Docker Compose stop:  ${COMPOSE_CMD} down"
    echo ""
    echo -e "${GREEN}🎉 Deployment complete!${NC}"
else
    echo -e "${RED}❌ Container failed to start. Checking logs...${NC}"
    docker logs ${PROJECT_NAME} 2>&1 | tail -20
    exit 1
fi

