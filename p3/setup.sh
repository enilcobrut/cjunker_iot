#!/bin/bash

# Mettre à jour les paquets
sudo apt update

# Installer Docker
sudo apt install -y docker.io

# Démarrer Docker et l'activer au démarrage
sudo systemctl start docker
sudo systemctl enable docker

# Installer K3d
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

# Installer kubectl (client Kubernetes)
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
