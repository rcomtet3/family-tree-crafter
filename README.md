# Family Tree Crafter

Application web d'arbre généalogique basée sur une architecture microservices.

## Architecture

```
family-tree-crafter/
├── frontend/              # Applications frontend
├── infrastructure/        # Composants d'infrastructure (Spring Cloud)
├── services/              # Microservices métier
└── docker/                # Configurations Docker
```

### Infrastructure

| Service | Rôle |
|---------|------|
| **discovery-server** | Service de découverte (Netflix Eureka) - enregistre etlocalise les microservices |
| **config-server** | Configuration centralisée (Spring Cloud Config) - gestioncentralisée des propriétés |
| **api-gateway** | Point d'entrée unique (Spring Cloud Gateway) - routage, authentification, rate limiting |

### Services Métier

| Service | Rôle |
|---------|------|
| **auth-service** | Authentification et gestion des utilisateurs (intégration Keycloak) |
| **person-service** | Gestion des personnes (CRUD, coordonnées, informations personnelles) |
| **family-service** | Gestion des familles et des relations |
| **tree-service** | Construction et visualisation de l'arbre généalogique |

### Frontend

| Application | Description |
|-------------|-------------|
| **family-tree-crafter-frontend** | Application React + Vite + TypeScript |

## Technologies

- **Backend**: Java 21, Spring Boot 3.x, Spring Cloud
- **Frontend**: React 18, Vite, TypeScript
- **Conteneurisation**: Docker, Docker Compose

## Démarrage

Voir le fichier `docker/docker-compose.yml` pour lancer l'infrastructure complète.

## Structure des commits recommandé

```
feat:     Nouvelle fonctionnalité
fix:      Correction de bug
refactor: Refactorisation
chore:    Tâche de maintenance
docs:     Documentation
```
