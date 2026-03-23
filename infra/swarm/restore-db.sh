#!/bin/bash
# ──────────────────────────────────────────────
# Restaure la base PostgreSQL depuis un backup
# Usage : ./restore-db.sh backups/nebula_20260331_120000.sql
# ──────────────────────────────────────────────

set -e

BACKUP_FILE="$1"

if [ -z "$BACKUP_FILE" ]; then
  echo "Usage : ./restore-db.sh <fichier_backup.sql>"
  echo ""
  echo "Backups disponibles :"
  ls -la backups/*.sql 2>/dev/null || echo "  Aucun backup trouvé"
  exit 1
fi

if [ ! -f "$BACKUP_FILE" ]; then
  echo "Erreur : fichier $BACKUP_FILE introuvable"
  exit 1
fi

PG_CONTAINER=$(docker ps -q -f name=nebula_postgres)

if [ -z "$PG_CONTAINER" ]; then
  echo "Erreur : conteneur PostgreSQL introuvable"
  exit 1
fi

echo "=== Restauration de $BACKUP_FILE ==="
echo "ATTENTION : cela va écraser la base actuelle !"
read -p "Continuer ? (oui/non) : " CONFIRM

if [ "$CONFIRM" != "oui" ]; then
  echo "Annulé."
  exit 0
fi

cat "$BACKUP_FILE" | docker exec -i "$PG_CONTAINER" psql -U nebula -d nebula

echo "Restauration terminée."
