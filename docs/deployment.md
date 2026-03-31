# Déploiement from scratch

## Prérequis

- 3 VMs avec Docker installé
- Un compte Docker Hub
- Accès SSH aux VMs

## 1. Installer Docker sur chaque VM

```bash
ssh -p 2221 etudiant@10.210.0.11  # VM1
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker etudiant
exit  # se reconnecter pour que le groupe soit pris en compte
```

Répéter pour VM2 (port 2222) et VM3 (port 2223).

## 2. Initialiser le cluster Swarm

Sur VM1 (manager) :
```bash
./init-cluster.sh
```

Copier la commande `docker swarm join` affichée, puis sur VM2 et VM3 :
```bash
docker swarm join --token SWMTKN-xxx IP_VM1:2377
```

Vérifier sur VM1 :
```bash
docker node ls
# Doit afficher 3 noeuds
```

## 3. Créer les secrets

Sur VM1 :
```bash
./create-secrets.sh
```

## 4. Pousser les images

Depuis ta machine locale :
```bash
# Login Docker Hub
docker login

# Build et push chaque service
docker build --build-arg SERVICE=api -t toncompte/nebula-api:latest .
docker push toncompte/nebula-api:latest

docker build --build-arg SERVICE=web -t toncompte/nebula-web:latest .
docker push toncompte/nebula-web:latest

docker build --build-arg SERVICE=media -t toncompte/nebula-media:latest .
docker push toncompte/nebula-media:latest

docker build --build-arg SERVICE=notifications -t toncompte/nebula-notifications:latest .
docker push toncompte/nebula-notifications:latest

docker build --build-arg SERVICE=search -t toncompte/nebula-search:latest .
docker push toncompte/nebula-search:latest
```

## 5. Copier les fichiers sur VM1

```bash
scp -P 2221 infra/swarm/docker-stack.yml etudiant@10.210.0.11:~/nebula/
scp -P 2221 infra/monitoring/prometheus.yml etudiant@10.210.0.11:~/nebula/infra/monitoring/
scp -P 2221 -r infra/monitoring/grafana etudiant@10.210.0.11:~/nebula/infra/monitoring/
```

## 6. Déployer

Sur VM1 :
```bash
cd ~/nebula
export REGISTRY=docker.io/toncompte
export TAG=latest
docker stack deploy -c docker-stack.yml nebula
```

## 7. Vérifier

```bash
# Voir les services
docker stack services nebula

# Voir les logs d'un service
docker service logs nebula_api

# Tester
curl http://IP_VM1/api/health
curl http://IP_VM1/health
```
