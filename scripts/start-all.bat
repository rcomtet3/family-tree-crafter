@echo off
echo === Starting Family Tree Crafter Infrastructure ===

echo [1/3] Starting discovery-server on port 8761...
cd infrastructure\discovery-server
start "discovery-server" cmd /c "mvnw spring-boot:run -DskipTests"

echo [2/3] Waiting for discovery-server...
:wait_discovery
ping -n 2 127.0.0.1 >nul
curl -s http://localhost:8761 >nul 2>&1
if errorlevel 1 goto wait_discovery
echo discovery-server is up!

echo [2/3] Starting config-server on port 8888...
cd ..\..\infrastructure\config-server
start "config-server" cmd /c "mvnw spring-boot:run -DskipTests"

echo Waiting for config-server...
:wait_config
ping -n 2 127.0.0.1 >nul
curl -s http://localhost:8888/actuator/health >nul 2>&1
if errorlevel 1 goto wait_config
echo config-server is up!

echo [3/3] Starting person-service on port 8082...
cd ..\..\services\person-service
start "person-service" cmd /c "mvnw spring-boot:run -DskipTests"

echo All services started!
pause
