@echo off
REM One-Click Docker Deploy Script for Uptime Kuma (Windows)
REM This script sets up and deploys Uptime Kuma using Docker Compose

setlocal enabledelayedexpansion

REM Configuration
set PROJECT_NAME=uptime-kuma
set PORT=3001
set DATA_DIR=.\data

echo.
echo ========================================
echo  Uptime Kuma - One-Click Docker Deploy
echo ========================================
echo.

REM Check if Docker is installed
docker --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Docker is not installed. Please install Docker Desktop first.
    echo Visit: https://docs.docker.com/get-docker/
    pause
    exit /b 1
)

echo [OK] Docker found

REM Check if Docker daemon is running
docker info >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Docker daemon is not running. Please start Docker Desktop.
    pause
    exit /b 1
)

echo [OK] Docker daemon is running

REM Create data directory if it doesn't exist
if not exist "%DATA_DIR%" (
    echo [INFO] Creating data directory...
    mkdir "%DATA_DIR%"
    echo [OK] Data directory created
) else (
    echo [OK] Data directory exists
)

REM Create compose.yaml
echo [INFO] Setting up docker-compose configuration...
(
echo services:
echo   uptime-kuma:
echo     image: louislam/uptime-kuma:2
echo     container_name: %PROJECT_NAME%
echo     restart: unless-stopped
echo     volumes:
echo       - %DATA_DIR%:/app/data
echo     ports:
echo       - "%PORT%:3001"
echo     environment:
echo       - UPTIME_KUMA_PORT=3001
) > compose.yaml

echo [OK] Docker Compose configuration ready

REM Check if container exists
docker ps -a --format "{{.Names}}" | findstr /C:"%PROJECT_NAME%" >nul 2>&1
if not errorlevel 1 (
    echo [WARN] Container '%PROJECT_NAME%' already exists
    set /p REMOVE_CONTAINER="Do you want to stop and remove the existing container? (Y/N): "
    if /i "!REMOVE_CONTAINER!"=="Y" (
        echo [INFO] Stopping existing container...
        docker compose down 2>nul
        docker stop %PROJECT_NAME% 2>nul
        docker rm %PROJECT_NAME% 2>nul
        echo [OK] Existing container removed
    ) else (
        echo [INFO] Keeping existing container. Use 'docker start %PROJECT_NAME%' to start it.
        pause
        exit /b 0
    )
)

REM Pull the latest image
echo [INFO] Pulling latest Uptime Kuma image...
docker pull louislam/uptime-kuma:2

REM Start the container
echo [INFO] Starting Uptime Kuma container...
docker compose up -d

REM Wait a moment
timeout /t 2 /nobreak >nul

REM Check if container is running
docker ps --format "{{.Names}}" | findstr /C:"%PROJECT_NAME%" >nul 2>&1
if not errorlevel 1 (
    echo.
    echo [OK] Uptime Kuma is now running!
    echo.
    echo ========================================
    echo  Access your dashboard:
    echo  Local:   http://localhost:%PORT%
    echo.
    echo  Data is stored in: %CD%\%DATA_DIR%
    echo.
    echo  Useful commands:
    echo    View logs:    docker logs -f %PROJECT_NAME%
    echo    Stop:         docker stop %PROJECT_NAME%
    echo    Start:        docker start %PROJECT_NAME%
    echo    Restart:      docker restart %PROJECT_NAME%
    echo    Remove:       docker rm -f %PROJECT_NAME%
    echo    Docker Compose stop:  docker compose down
    echo.
    echo [SUCCESS] Deployment complete!
) else (
    echo [ERROR] Container failed to start. Checking logs...
    docker logs %PROJECT_NAME% 2>&1 | more
    pause
    exit /b 1
)

pause

