# Architecture Nebula

## Vue d'ensemble

```
Internet
   │
   ▼ (port 80)
┌──────────┐
│  TRAEFIK │ ← seul point d'entrée
└────┬─────┘
     │ réseau "public"
     ├──────────────────────────────────────────┐
     │              │            │              │
  ┌──▼──┐     ┌────▼───┐  ┌────▼───┐    ┌─────▼──┐
  │ WEB │     │  API   │  │ MEDIA  │    │ SEARCH │
  │:3000│     │ :3001  │  │ :3003  │    │ :3005  │
  └─────┘     └───┬────┘  └───┬────┘    └───┬────┘
                  │ réseau "internal"        │
     ┌────────────┼────────────┼────────────┘
     │            │            │
┌────▼───┐  ┌────▼────┐  ┌───▼────┐  ┌───────────────┐
│POSTGRES│  │RABBITMQ │  │ MINIO  │  │ NOTIFICATIONS │
│  :5432 │  │  :5672  │  │ :9000  │  │    :3004      │
└────────┘  └─────────┘  └────────┘  └───────────────┘
                │
          réseau "monitoring"
                │
     ┌──────────┼──────────┐
     │          │          │
┌────▼─────┐ ┌─▼──────┐ ┌─▼────────┐
│PROMETHEUS│ │GRAFANA │ │NODE EXP. │
│  :9090   │ │ :3000  │ │cADVISOR  │
└──────────┘ └────────┘ └──────────┘
```

## Services applicatifs

| Service | Rôle | Port |
|---|---|---|
| web | Frontend Next.js | 3000 |
| api | Backend NestJS, CRUD users/posts | 3001 |
| media | Upload fichiers vers MinIO | 3003 |
| notifications | Consomme les events RabbitMQ | 3004 |
| search | Recherche de posts (appelle l'API) | 3005 |

## Infrastructure

| Service | Rôle |
|---|---|
| PostgreSQL | Base de données (users, posts) |
| RabbitMQ | File de messages asynchrone |
| MinIO | Stockage de fichiers (médias) |
| Redis | Cache |

## Monitoring

| Service | Rôle | Mode |
|---|---|---|
| Prometheus | Collecte les métriques | 1 instance |
| Grafana | Affiche les dashboards | 1 instance |
| Node Exporter | Métriques système (CPU, RAM) | 1 par VM (global) |
| cAdvisor | Métriques par conteneur | 1 par VM (global) |

## Réseaux

| Réseau | Type | Rôle |
|---|---|---|
| public | overlay | Traefik ↔ services exposés |
| internal | overlay (internal) | Services ↔ bases de données, isolé d'internet |
| monitoring | overlay | Prometheus ↔ services à surveiller |

## Flux de données

1. **Persistance** : API → PostgreSQL (CRUD users/posts)
2. **Asynchrone** : API publie `post.created` → RabbitMQ → Notifications consomme
3. **Stockage** : Media → MinIO (upload) → publie `media.uploaded` → RabbitMQ → Notifications
4. **Inter-service** : Search → appelle API `/posts` → filtre les résultats

## Routage Traefik

| URL | Service |
|---|---|
| `/` | web |
| `/api/*` | api (strip /api) |
| `/media/*` | media (strip /media) |
| `/search` | search |
| `/grafana` | grafana |
| `/prometheus` | prometheus |
