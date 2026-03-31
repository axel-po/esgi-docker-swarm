# Restauration base de données

## Faire un backup

```bash
cd infra/swarm
./backup-db.sh
# → crée backups/nebula_YYYYMMDD_HHMMSS.sql
```

## Restaurer un backup

```bash
./restore-db.sh backups/nebula_20260331_120000.sql
# Demande confirmation avant d'écraser la base
```

## Vérifier après restauration

```bash
# Tester que l'API répond
curl http://IP_VM1/api/health

# Tester que les données sont là
curl http://IP_VM1/api/posts
```
