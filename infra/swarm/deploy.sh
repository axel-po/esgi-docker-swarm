#!/bin/bash

set -e

export REGISTRY=${REGISTRY:-"docker.io/toncompte"}
export TAG=${TAG:-"latest"}

echo "=== Déploiement Nebula ==="
echo "Registry : $REGISTRY"
echo "Tag      : $TAG"
echo ""

echo "=== État du cluster ==="
docker node ls
echo ""

echo "=== Déploiement de la stack ==="
docker stack deploy -c docker-stack.yml nebula

echo ""
echo "=== Déploiement lancé ! ==="
echo ""
echo "Commandes utiles :"
echo "  docker stack services nebula     → voir les services"
echo "  docker service logs nebula_api   → voir les logs de l'API"
echo "  docker service scale nebula_api=3 → scaler l'API"
echo "  docker stack rm nebula           → supprimer la stack"
