#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "Project directory: $PROJECT_DIR"

cd "$PROJECT_DIR" || exit 1

echo "=== Arrêt de tous les services ==="

# Arrêter le frontend (npm)
echo "Arrêt du frontend..."
taskkill /F /IM node.exe 2>/dev/null || true

# Arrêter Keycloak Docker
echo "Arrêt de Keycloak..."
docker stop keycloak 2>/dev/null || true
docker rm keycloak 2>/dev/null || true

# Supprimer les déployments K8s
echo "Suppression des ressources Kubernetes..."
kubectl delete -f k8s/person-service/ --ignore-not-found=true 2>/dev/null || true

echo ""
echo "=== Démarrage de tous les services ==="

# Démarrer Keycloak
echo "Démarrage de Keycloak..."
docker run -d --name keycloak -p 8180:8080 \
  -e KEYCLOAK_ADMIN=admin \
  -e KEYCLOAK_ADMIN_PASSWORD=admin \
  quay.io/keycloak/keycloak:24.0.4 start-dev

echo "Attente de Keycloak (30s)..."
sleep 30

# Configurer Keycloak
echo "Configuration de Keycloak..."
KEYCLOAK_URL="http://localhost:8180"
ADMIN_TOKEN=$(curl -s -X POST "$KEYCLOAK_URL/realms/master/protocol/openid-connect/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "username=admin" -d "password=admin" \
  -d "grant_type=password" -d "client_id=admin-cli" \
  | grep -o '"access_token":"[^"]*"' | cut -d'"' -f4)

# Créer le realm
curl -s -X POST "$KEYCLOAK_URL/admin/realms" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"realm":"family-tree","enabled":true}' 2>/dev/null || true

# Créer client frontend
curl -s -X POST "$KEYCLOAK_URL/admin/realms/family-tree/clients" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"clientId":"family-tree-frontend","name":"Family Tree Frontend","enabled":true,"publicClient":true,"directAccessGrantsEnabled":true,"standardFlowEnabled":true,"redirectUris":["http://localhost/*"],"webOrigins":["http://localhost"],"protocol":"openid-connect"}' 2>/dev/null || true

# Créer client API
curl -s -X POST "$KEYCLOAK_URL/admin/realms/family-tree/clients" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"clientId":"family-tree-api","name":"Family Tree API","enabled":true,"bearerOnly":true,"protocol":"openid-connect"}' 2>/dev/null || true

# Créer utilisateur test
curl -s -X POST "$KEYCLOAK_URL/admin/realms/family-tree/users" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"username":"testuser","email":"test@example.com","enabled":true,"emailVerified":true,"firstName":"Test","lastName":"User","credentials":[{"type":"password","value":"testpassword","temporary":false}]}' 2>/dev/null || true

# Builder person-service
echo "Build de person-service..."
cd "$PROJECT_DIR/services/person-service"
mvn clean package -DskipTests -Djacoco.skip=true -q

# Builder l'image Docker
echo "Build de l'image Docker..."
docker build -t family-tree/person-service:latest -f src/main/docker/Dockerfile . 2>/dev/null || true

# Déployer sur K8s
echo "Déploiement sur Kubernetes..."
cd "$PROJECT_DIR/k8s"
kubectl apply -f person-service/
kubectl apply -f common/

# Attendre que person-service soit prêt
echo "Attente de person-service..."
kubectl wait --for=condition=ready pod -l app=person-service --timeout=60s 2>/dev/null || true

# Démarrer le frontend
echo "Démarrage du frontend..."
cd "$PROJECT_DIR/frontend"
npm run dev &

cd "$PROJECT_DIR"

echo ""
echo "=== Services démarrés ==="
echo "- Keycloak: http://localhost:8180 (admin/admin)"
echo "- API: http://localhost/persons"
echo "- Frontend: http://localhost:3000"
echo ""
echo "Utilisateur test: testuser / testpassword"
