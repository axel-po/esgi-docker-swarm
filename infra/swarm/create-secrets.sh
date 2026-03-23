#!/bin/bash
# ──────────────────────────────────────────────
# Crée les secrets Docker pour le cluster Swarm
# À lancer UNE SEULE FOIS sur le manager (VM1)
# ──────────────────────────────────────────────

set -e

echo "=== Création des secrets Nebula ==="
echo ""

read -s -p "Mot de passe PostgreSQL : " DB_PASS
echo ""
read -s -p "Mot de passe RabbitMQ : " RABBITMQ_PASS
echo ""
read -s -p "Clé accès MinIO : " MINIO_ACCESS
echo ""
read -s -p "Clé secrète MinIO : " MINIO_SECRET
echo ""

echo "$DB_PASS" | docker secret create db_password -
echo "postgresql://nebula:${DB_PASS}@postgres:5432/nebula" | docker secret create db_url -
echo "$RABBITMQ_PASS" | docker secret create rabbitmq_password -
echo "$MINIO_ACCESS" | docker secret create minio_access_key -
echo "$MINIO_SECRET" | docker secret create minio_secret_key -

echo ""
echo "=== 5 secrets créés ==="
docker secret ls
