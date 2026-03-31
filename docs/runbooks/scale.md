# Scale (montée en charge)

## Scaler un service

```bash
# Passer l'API de 2 à 5 instances
docker service scale nebula_api=5

# Vérifier la répartition
docker service ps nebula_api
# → affiche sur quelles VMs tournent les 5 instances
```

## Scaler plusieurs services

```bash
docker service scale nebula_api=5 nebula_web=3 nebula_media=3
```

## Revenir au nombre initial

```bash
docker service scale nebula_api=2
```

## Vérifier la charge

```bash
# Voir toutes les tâches du cluster
docker node ps $(docker node ls -q)

# Voir les ressources utilisées
docker stats
```
