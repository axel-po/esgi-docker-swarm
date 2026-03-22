#!/bin/bash
# ──────────────────────────────────────────────
# Initialise le cluster Docker Swarm
# À lancer sur la VM1 (manager)
# ──────────────────────────────────────────────

set -e

echo "=== Initialisation du Swarm ==="
docker swarm init --advertise-addr $(hostname -I | awk '{print $1}')

echo ""
echo "=== Token pour rejoindre le cluster ==="
echo "Copie cette commande et lance-la sur VM2 et VM3 :"
echo ""
docker swarm join-token worker
echo ""

echo "=== Labels pour le manager ==="
docker node update --label-add role=manager $(hostname)

echo ""
echo "=== Swarm prêt ! ==="
echo "Attends que les workers aient rejoint, puis lance : ./deploy.sh"
