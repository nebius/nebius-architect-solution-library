#!/bin/bash
# Parch ArgoCD for custom deployKF resources
cd argocd-plugin
./patch_argocd.sh

sleep 10
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=argocd-repo-server --timeout=600s -n argocd
echo "ArgoCD patched."

# Deploy config-file for kubeflow
cd ./example-app-of-apps
cp /configs/app-of-apps.yaml ./
kubectl apply -f ./app-of-apps.yaml

# Install kubeflow
cd ../../scripts/
chmod +x sync_argocd_apps.sh
./sync_argocd_apps.sh