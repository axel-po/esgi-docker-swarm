# Mise à jour d'un service

## Rolling update (zéro downtime)

### 1. Builder et pusher la nouvelle image

```bash
docker build --build-arg SERVICE=api -t toncompte/nebula-api:v2.0.0 .
docker push toncompte/nebula-api:v2.0.0
```

### 2. Mettre à jour le service sur le cluster

```bash
docker service update \
  --image toncompte/nebula-api:v2.0.0 \
  nebula_api
```

### 3. Vérifier le déploiement

```bash
# Voir l'état du rolling update
docker service ps nebula_api

# Vérifier que les nouvelles instances sont up
docker service ls
```

Swarm met à jour 1 instance à la fois, attend 10s, puis passe à la suivante.
Si une instance échoue, Swarm arrête le rollout automatiquement.
