# Family Tree Crafter - Start All Services
# Run from anywhere

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectDir = (Get-Item $scriptDir).Parent.FullName

Write-Host "Project directory: $projectDir" -ForegroundColor Cyan

Set-Location $projectDir

Write-Host "=== Arrêt de tous les services ===" -ForegroundColor Yellow

# Arrêter le frontend
Write-Host "Arrêt du frontend..." -ForegroundColor Cyan
Get-Process -Name node -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2

# Arrêter Keycloak Docker
Write-Host "Arrêt de Keycloak..." -ForegroundColor Cyan
docker stop keycloak 2>$null
docker rm keycloak 2>$null

# Supprimer les déployments K8s
Write-Host "Suppression des ressources Kubernetes..." -ForegroundColor Cyan
kubectl delete -f k8s/person-service/ --ignore-not-found=true 2>$null

Write-Host ""
Write-Host "=== Démarrage de tous les services ===" -ForegroundColor Yellow

# Démarrer Keycloak
Write-Host "Démarrage de Keycloak..." -ForegroundColor Cyan
docker run -d --name keycloak -p 8180:8080 -e KEYCLOAK_ADMIN=admin -e KEYCLOAK_ADMIN_PASSWORD=admin quay.io/keycloak/keycloak:24.0.4 start-dev

Write-Host "Attente de Keycloak (30s)..." -ForegroundColor Cyan
Start-Sleep -Seconds 30

# Configurer Keycloak
Write-Host "Configuration de Keycloak..." -ForegroundColor Cyan
$keycloakUrl = "http://localhost:8180"

$adminResponse = Invoke-RestMethod -Uri "$keycloakUrl/realms/master/protocol/openid-connect/token" `
  -Method POST `
  -ContentType "application/x-www-form-urlencoded" `
  -Body "username=admin&password=admin&grant_type=password&client_id=admin-cli"
$adminToken = $adminResponse.access_token

$headers = @{
  "Authorization" = "Bearer $adminToken"
  "Content-Type" = "application/json"
}

# Créer le realm
Invoke-RestMethod -Uri "$keycloakUrl/admin/realms" -Method POST -Headers $headers -Body '{"realm":"family-tree","enabled":true}' 2>$null

# Créer client frontend
Invoke-RestMethod -Uri "$keycloakUrl/admin/realms/family-tree/clients" -Method POST -Headers $headers -Body '{"clientId":"family-tree-frontend","name":"Family Tree Frontend","enabled":true,"publicClient":true,"directAccessGrantsEnabled":true,"standardFlowEnabled":true,"redirectUris":["http://localhost/*"],"webOrigins":["http://localhost"],"protocol":"openid-connect"}' 2>$null

# Créer client API
Invoke-RestMethod -Uri "$keycloakUrl/admin/realms/family-tree/clients" -Method POST -Headers $headers -Body '{"clientId":"family-tree-api","name":"Family Tree API","enabled":true,"bearerOnly":true,"protocol":"openid-connect"}' 2>$null

# Créer utilisateur test
Invoke-RestMethod -Uri "$keycloakUrl/admin/realms/family-tree/users" -Method POST -Headers $headers -Body '{"username":"testuser","email":"test@example.com","enabled":true,"emailVerified":true,"firstName":"Test","lastName":"User","credentials":[{"type":"password","value":"testpassword","temporary":false}]}' 2>$null

# Builder person-service
Write-Host "Build de person-service..." -ForegroundColor Cyan
Set-Location "$projectDir\services\person-service"
mvn clean package -DskipTests -Djacoco.skip=true -q

# Builder l'image Docker
Write-Host "Build de l'image Docker..." -ForegroundColor Cyan
docker build -t family-tree/person-service:latest -f src/main/docker/Dockerfile . 2>$null

# Déployer sur K8s
Write-Host "Déploiement sur Kubernetes..." -ForegroundColor Cyan
Set-Location "$projectDir\k8s"
kubectl apply -f person-service/
kubectl apply -f common/

# Attendre que person-service soit prêt
Write-Host "Attente de person-service..." -ForegroundColor Cyan
kubectl wait --for=condition=ready pod -l app=person-service --timeout=60s 2>$null

# Démarrer le frontend
Write-Host "Démarrage du frontend..." -ForegroundColor Cyan
Set-Location "$projectDir\frontend"
Start-Process "npm" -ArgumentList "run","dev" -NoNewWindow

Set-Location $projectDir

Write-Host ""
Write-Host "=== Services démarrés ===" -ForegroundColor Green
Write-Host "- Keycloak: http://localhost:8180 (admin/admin)" -ForegroundColor White
Write-Host "- API: http://localhost/persons" -ForegroundColor White
Write-Host "- Frontend: http://localhost:3000" -ForegroundColor White
Write-Host "" -ForegroundColor White
Write-Host "Utilisateur test: testuser / testpassword" -ForegroundColor Cyan
