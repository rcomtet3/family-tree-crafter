#!/bin/bash

echo "=== Starting Family Tree Crafter Infrastructure ==="

echo "[1/3] Starting discovery-server on port 8761..."
cd infrastructure/discovery-server
./mvnw spring-boot:run -DskipTests &
DISCOVERY_PID=$!
cd ../..

echo "[2/3] Waiting for discovery-server to be ready..."
until curl -s http://localhost:8761 > /dev/null 2>&1; do
    sleep 2
done
echo "discovery-server is up!"

echo "[3/3] Starting config-server on port 8888..."
cd infrastructure/config-server
./mvnw spring-boot:run -DskipTests &
CONFIG_PID=$!
cd ../..

echo "Waiting for config-server to be ready..."
until curl -s http://localhost:8888/actuator/health > /dev/null 2>&1; do
    sleep 2
done
echo "config-server is up!"

echo "[4/4] Starting person-service on port 8082..."
cd services/person-service
./mvnw spring-boot:run -DskipTests
