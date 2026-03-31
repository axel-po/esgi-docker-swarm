# Retour arrière (rollback)

## Si une mise à jour échoue

```bash
# Rollback vers la version précédente
docker service rollback nebula_api
```

## Vérifier le rollback

```bash
# Voir l'historique des tâches
docker service ps nebula_api

# Vérifier que le service fonctionne
curl http://IP_VM1/api/health
```

## Rollback vers une version spécifique

```bash
# Forcer une image précise
docker service update \
  --image toncompte/nebula-api:v1.0.0 \
  nebula_api
```
