#!/bin/bash
# ──────────────────────────────────────────────
# Sauvegarde la base PostgreSQL depuis le cluster Swarm

# ──────────────────────────────────────────────

set -e

BACKUP_DIR="./backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="${BACKUP_DIR}/nebula_${TIMESTAMP}.sql"

mkdir -p "$BACKUP_DIR"

# Trouve le conteneur PostgreSQL
PG_CONTAINER=$(docker ps -q -f name=nebula_postgres)

if [ -z "$PG_CONTAINER" ]; then
  echo "Erreur : conteneur PostgreSQL introuvable"
  exit 1
fi

echo "=== Backup de la base Nebula ==="
docker exec "$PG_CONTAINER" pg_dump -U nebula nebula > "$BACKUP_FILE"

echo "Backup sauvegardé : $BACKUP_FILE"
echo "Taille : $(du -h "$BACKUP_FILE" | cut -f1)"
