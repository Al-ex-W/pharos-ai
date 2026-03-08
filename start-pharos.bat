@echo off
title Pharos AI - Starting Services
echo ========================================
echo  Pharos AI - Service Launcher
echo ========================================
echo.

cd /d "%~dp0"

:: Kill any existing engine
echo [1/4] Stopping old engine processes...
taskkill /F /IM java.exe 2>nul
timeout /t 2 /nobreak >nul

:: Start Docker (postgres)
echo [2/4] Starting PostgreSQL (Docker)...
docker compose up -d postgres
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Docker failed. Is Docker Desktop running?
    pause
    exit /b 1
)
timeout /t 3 /nobreak >nul

:: Start Scala engine
echo [3/4] Starting Scala intelligence engine on :4100...
start "Pharos Engine" /min cmd /c ""%USERPROFILE%\.jdks\openjdk-23.0.2\bin\java.exe" -Xmx512m -DPHAROS_DB_HOST=localhost -DPHAROS_DB_PORT=5434 -DPHAROS_DB_NAME=pharos -DPHAROS_DB_USER=pharos -DPHAROS_DB_PASSWORD=pharos -DPHAROS_ENGINE_HOST=0.0.0.0 -DPHAROS_ENGINE_PORT=4100 -jar scala-engine\target\scala-3.4.1\pharos-engine-assembly-0.8.0.jar"
timeout /t 5 /nobreak >nul

:: Start Next.js frontend
echo [4/4] Starting Next.js frontend on :3001...
start "Pharos Frontend" cmd /c "npm run dev -- --port 3001"

echo.
echo ========================================
echo  All services starting!
echo  Frontend:  http://localhost:3001
echo  Engine:    http://localhost:4100
echo  Postgres:  localhost:5434
echo ========================================
echo.
echo Waiting for engine health check...
timeout /t 10 /nobreak >nul

curl -sf http://localhost:4100/health >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo Engine: OK
) else (
    echo Engine: still starting (check the Engine window)
)

curl -sf http://localhost:3001 -o nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo Frontend: OK
) else (
    echo Frontend: still starting (check the Frontend window)
)

echo.
echo Press any key to close this launcher (services keep running).
pause >nul
