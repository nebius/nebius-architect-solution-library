#!/bin/bash
ARGOCD_NAMESPACE="argocd"
ARGOCD_USERNAME="admin"
ARGOCD_PASSWORD=$(
  kubectl -n "$ARGOCD_NAMESPACE" get secret "argocd-initial-admin-secret" -o jsonpath="{.data.password}" \
  | base64 -d
)

export ARGOCD_OPTS="--port-forward --port-forward-namespace '$ARGOCD_NAMESPACE'"
argocd login --username "$ARGOCD_USERNAME" --password "$ARGOCD_PASSWORD"
argocd app delete -y deploykf-app-of-apps

until ! $(argocd app list -o name | grep -qx argocd/deploykf-app-of-apps); do echo "Waiting for deletion."; sleep 5; done

# List of namespaces to delete
declare -a namespaces=(
  "cert-manager"
  "deploykf-auth"
  "deploykf-dashboard"
  "deploykf-istio-gateway"
  "deploykf-minio"
  "deploykf-mysql"
  "istio-system"
  "kubeflow"
  "kyverno"
  "kubeflow-argo-workflows"
)

# Loop through each namespace and attempt to delete it
for ns in "${namespaces[@]}"; do
  echo "Deleting namespace: $ns"
  kubectl delete namespace "$ns" --ignore-not-found
  if [ $? -ne 0 ]; then
    echo "Error occurred while deleting $ns, skipping..."
  fi
done
echo "Namespace deletion process completed."
