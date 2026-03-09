Write-Host "=== Starting Family Tree Crafter Infrastructure ===" -ForegroundColor Cyan

Write-Host "[1/3] Starting discovery-server on port 8761..." -ForegroundColor Yellow
Start-Process -FilePath "cmd" -ArgumentList "/c cd infrastructure\discovery-server && mvnw spring-boot:run -DskipTests" -NoNewWindow

Write-Host "Waiting for discovery-server..." -ForegroundColor Yellow
while (-not (Test-NetConnection -ComputerName localhost -Port 8761 -InformationLevel Quiet)) {
    Start-Sleep -Seconds 2
}
Write-Host "discovery-server is up!" -ForegroundColor Green

Write-Host "[2/3] Starting config-server on port 8888..." -ForegroundColor Yellow
Start-Process -FilePath "cmd" -ArgumentList "/c cd infrastructure\config-server && mvnw spring-boot:run -DskipTests" -NoNewWindow

Write-Host "Waiting for config-server..." -ForegroundColor Yellow
while (-not (Test-NetConnection -ComputerName localhost -Port 8888 -InformationLevel Quiet)) {
    Start-Sleep -Seconds 2
}
Write-Host "config-server is up!" -ForegroundColor Green

Write-Host "[3/3] Starting person-service on port 8082..." -ForegroundColor Yellow
Start-Process -FilePath "cmd" -ArgumentList "/c cd services\person-service && mvnw spring-boot:run -DskipTests" -NoNewWindow

Write-Host "All services started!" -ForegroundColor Cyan
Write-Host "Eureka:     http://localhost:8761" -ForegroundColor White
Write-Host "Config:     http://localhost:8888" -ForegroundColor White
Write-Host "Person API: http://localhost:8082/persons" -ForegroundColor White
