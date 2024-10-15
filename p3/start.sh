#!/bin/bash

# Variables
CLUSTER_NAME="cjunkercluster"
ARGOCD_NAMESPACE="argocd"
DEV_NAMESPACE="dev"
ARGOCD_APP_NAME="cjunkeriot"
GITHUB_REPO_URL="https://github.com/enilcobrut/cjunker_iot"
GITHUB_REPO_PATH="configs"
GITHUB_USERNAME="enilcobrut"

if k3d cluster get "$CLUSTER_NAME" >/dev/null 2>&1; then
    echo "Cluster '$CLUSTER_NAME' already exists. Skipping cluster creation."
else
    echo "Creating K3d cluster..."
    k3d cluster create "$CLUSTER_NAME" --port "8888:30001@server:0"
fi

echo "Waiting for the cluster to be ready..."
sleep 10

if kubectl get namespace "$ARGOCD_NAMESPACE" >/dev/null 2>&1; then
    echo "Namespace '$ARGOCD_NAMESPACE' already exists. Skipping namespace creation."
else
    echo "Creating Argo CD namespace..."
    kubectl create namespace "$ARGOCD_NAMESPACE"
fi

if kubectl get deployment argocd-server -n "$ARGOCD_NAMESPACE" >/dev/null 2>&1; then
    echo "Argo CD is already installed in namespace '$ARGOCD_NAMESPACE'. Skipping Argo CD installation."
else
    echo "Installing Argo CD..."
    kubectl apply -n "$ARGOCD_NAMESPACE" -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

    echo "Waiting for Argo CD pods to be ready..."
    kubectl rollout status deployment/argocd-server -n "$ARGOCD_NAMESPACE"
fi

if kubectl get namespace "$DEV_NAMESPACE" >/dev/null 2>&1; then
    echo "Namespace '$DEV_NAMESPACE' already exists. Skipping namespace creation."
else
    echo "Creating dev namespace..."
    kubectl create namespace "$DEV_NAMESPACE"
fi

echo "Exposing Argo CD API server..."
if pgrep -f "kubectl port-forward svc/argocd-server" >/dev/null; then
    echo "Port-forwarding is already running. Skipping."
else
    nohup kubectl port-forward svc/argocd-server -n "$ARGOCD_NAMESPACE" 8080:443 >/dev/null 2>&1 &
    sleep 5
fi

echo "Retrieving Argo CD admin password..."
ARGOCD_PASSWORD=$(kubectl get secret argocd-initial-admin-secret -n "$ARGOCD_NAMESPACE" -o jsonpath="{.data.password}" | base64 -d)
echo "Argo CD admin password: $ARGOCD_PASSWORD"

echo "Installing Argo CD CLI..."
if ! command -v argocd >/dev/null 2>&1; then
    VERSION=$(curl --silent "https://api.github.com/repos/argoproj/argo-cd/releases/latest" | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')
    sudo curl -sSL -o /usr/local/bin/argocd "https://github.com/argoproj/argo-cd/releases/download/${VERSION}/argocd-linux-amd64"
    sudo chmod +x /usr/local/bin/argocd
fi

echo "Logging into Argo CD..."
argocd login localhost:8080 --username admin --password "$ARGOCD_PASSWORD" --insecure

echo "Creating Argo CD Project 'developpment'..."
kubectl apply -n "$ARGOCD_NAMESPACE" -f - <<EOF
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: developpment
  namespace: $ARGOCD_NAMESPACE
spec:
  description: Project for development applications
  sourceRepos:
    - '*'
  destinations:
    - namespace: '*'
      server: '*'
  clusterResourceWhitelist:
    - group: '*'
      kind: '*'
EOF

echo "Creating Argo CD Application..."
kubectl apply -n "$ARGOCD_NAMESPACE" -f - <<EOF
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: $ARGOCD_APP_NAME
  namespace: $ARGOCD_NAMESPACE
spec:
  project: developpment  # Corrected project name
  source:
    repoURL: '$GITHUB_REPO_URL'
    targetRevision: HEAD
    path: '$GITHUB_REPO_PATH'
  destination:
    server: https://kubernetes.default.svc
    namespace: $DEV_NAMESPACE
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
EOF

echo "Waiting for the application to sync..."
argocd app wait "$ARGOCD_APP_NAME"

echo "Setup complete!"
echo "Access your application at: http://localhost:8888"
echo "Access Argo CD UI at: http://localhost:8080"
echo "Argo CD admin password: $ARGOCD_PASSWORD"
