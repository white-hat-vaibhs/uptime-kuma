# 🚀 Quick Deploy Guide

One-click deployment scripts for Uptime Kuma with Docker.

## Linux / macOS

### Option 1: Run the deploy script

```bash
./deploy.sh
```

### Option 2: Docker Compose (Manual)

```bash
# Create data directory
mkdir -p data

# Start the container
docker compose up -d
```

### Option 3: Docker Run (Manual)

```bash
# Create data directory
mkdir -p data

# Run container
docker run -d \
  --restart=always \
  -p 3001:3001 \
  -v "$(pwd)/data:/app/data" \
  --name uptime-kuma \
  louislam/uptime-kuma:2
```

## Windows

### Option 1: Run the deploy script

```cmd
deploy.bat
```

### Option 2: Docker Compose (Manual)

```cmd
REM Create data directory
mkdir data

REM Start the container
docker compose up -d
```

## Custom Port

Set the port before running:

**Linux/macOS:**
```bash
PORT=8080 ./deploy.sh
```

**Windows:**
Edit `deploy.bat` and change `set PORT=3001` to your desired port.

## Access

After deployment, access Uptime Kuma at:
- **Local:** http://localhost:3001
- **Network:** http://your-server-ip:3001

## Management Commands

### View Logs
```bash
docker logs -f uptime-kuma
```

### Stop Container
```bash
docker stop uptime-kuma
```

### Start Container
```bash
docker start uptime-kuma
```

### Restart Container
```bash
docker restart uptime-kuma
```

### Remove Container (keeps data)
```bash
docker rm -f uptime-kuma
```

### Stop and Remove (Docker Compose)
```bash
docker compose down
```

## Data Location

All data is stored in the `./data` directory:
- Database: `./data/kuma.db`
- Uploads: `./data/upload/`
- Screenshots: `./data/screenshots/`

**To backup:** Simply copy the `./data` directory.

**To restore:** Replace the `./data` directory with your backup.

## Troubleshooting

### Container won't start
```bash
docker logs uptime-kuma
```

### Port already in use
Change the port in `compose.yaml` or use a different port:
```bash
PORT=8080 ./deploy.sh
```

### Permission issues (Linux)
```bash
sudo chown -R $USER:$USER ./data
```

### Docker daemon not running
Start Docker Desktop (Windows/macOS) or Docker service (Linux).

## Requirements

- Docker installed
- Docker Compose v2 (or docker-compose v1)
- At least 512MB RAM available
- Port 3001 (or custom port) available

