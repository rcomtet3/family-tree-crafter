# Family Tree Crafter

Application web d'arbre généalogique basée sur une architecture microservices avec Docker et Kubernetes.

## Architecture

```
family-tree-crafter/
├── frontend/              # Application React
├── services/              # Microservices
│   └── person-service/
├── k8s/                   # Manifests Kubernetes
└── docker/                # Configurations Docker
```

## Services

| Service | Port | Description |
|---------|------|-------------|
| **person-service** | 8082 | Gestion des personnes |

## Technologies

- **Backend**: Java 17, Spring Boot 3.x
- **Frontend**: React + Vite + TypeScript
- **Conteneurisation**: Docker
- **Orchestration**: Kubernetes

## Configuration Kubernetes

Les services utilisent des ConfigMaps pour la configuration :

```bash
kubectl apply -f k8s/person-configmap.yaml
kubectl apply -f k8s/person-deployment.yaml
kubectl apply -f k8s/person-service.yaml
```

## Docker

Build et run local :

```bash
cd services/person-service
./mvnw clean package -DskipTests
docker build -t family-tree/person-service:latest -f src/main/docker/Dockerfile .
docker run -p 8082:8082 family-tree/person-service:latest
```
