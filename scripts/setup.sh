#!/usr/bin/env bash

set -e

# This script sets up a k8s cluster using kind with ignite VMs as the k8s nodes
# and installs StorageOS in the provisioned k8s cluster.
#
# Setup config files:
# - kind-cluster.yaml can be used to configure the k8s cluster setup.

# Source the common variables.
source scripts/vars.sh

# Version of StorageOS to install by default.
CLUSTER_NAME="${1:-$DEFAULT_CLUSTER_NAME}"

# Create a kind-ignite k8s cluster.
echo ""
echo "⚠️  NOTE: kind-ignite support is not stable and may fail provisioning unexpectedly sometimes."
echo "   Delete the machines and retry if provisioning fails."
echo "   List of known failures: https://gist.github.com/darkowlzz/fc8a26a24c0a2aa499d3f9c4ced14754"
echo "   Please report any error that's not in the known failures list."
echo ""

sudo "$KIND_BIN" create cluster --image darkowlzz/node-ignite:test --ignite="$IGNITE_BIN" \
    --config=kind-cluster.yaml --name="$CLUSTER_NAME"
sudo "$IGNITE_BIN" exec "$CLUSTER_NAME-control-plane" cat /etc/kubernetes/admin.conf > "$CLUSTER_NAME-kubeconfig.yaml"

export KUBECONFIG="$CLUSTER_NAME-kubeconfig.yaml"

# Remove taint from master node. Do not fail if this doesn't succeeds, not a
# fatal error.
"$KUBECTL_BIN" taint nodes "$CLUSTER_NAME-control-plane" node-role.kubernetes.io/master- || true

echo ""
echo "ℹ️  Run \". .env\" to configure the current shell with the cluster."
echo ""
echo "Kubernetes cluster ready. Check the cluster nodes with:"
echo ""
echo "  kubectl get nodes"
