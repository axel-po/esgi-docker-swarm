# Maintenance d'un noeud

## Drainer un noeud (déplacer les conteneurs)

```bash
# Voir les noeuds
docker node ls

# Mettre le noeud en maintenance (les conteneurs migrent vers les autres noeuds)
docker node update --availability drain WORKER_ID

# Vérifier que les tâches ont migré
docker service ps nebula_api
```

## Réactiver le noeud après maintenance

```bash
docker node update --availability active WORKER_ID
```

## Retirer un noeud du cluster

Sur le noeud à retirer :
```bash
docker swarm leave
```

Sur le manager :
```bash
docker node rm WORKER_ID
```
