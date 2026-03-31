# Diagnostic post-mortem

## 1. Identifier le problème

```bash
# Voir l'état de tous les services
docker stack services nebula

# Un service a 0/2 replicas ? Regarder ses logs :
docker service logs nebula_api --tail 50

# Voir les tâches échouées
docker service ps nebula_api --no-trunc
```

## 2. Problèmes courants

### Un service crash en boucle
```bash
# Voir pourquoi il crash
docker service logs nebula_api --tail 100

# Causes possibles :
# - Variable d'env manquante
# - Base de données inaccessible
# - Port déjà utilisé
```

### Un noeud est down
```bash
# Voir l'état des noeuds
docker node ls
# Un noeud "Down" ? Swarm a déjà migré les conteneurs automatiquement.

# Vérifier :
docker service ps nebula_api
```

### La base de données est corrompue
```bash
# Restaurer depuis un backup
cd infra/swarm
./restore-db.sh backups/dernier_backup.sql
```

## 3. Monitoring

- Grafana : http://IP_VM1/grafana (admin/admin)
- Prometheus : http://IP_VM1/prometheus
- Traefik dashboard : http://IP_VM1:8080
