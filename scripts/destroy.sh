#!/usr/bin/env bash

set -e

# This script deletes the ignite VMs that are part of the k8s cluster.

# Source the common variables.
source scripts/vars.sh

CLUSTER_NAME="${1:-$DEFAULT_CLUSTER_NAME}"

echo ""

# Select the ignite VMs with the VM labels by cluster name "kind".
# VMS_R=$(sudo "$IGNITE_BIN" ps -q -a -f "{{.ObjectMeta.Labels}}=~$CLUSTER_LABEL:$CLUSTER_NAME")
# NOTE: Stop the VMs before rm. There was a bug in ignite due to which iptable
# rules were not cleaned up if the VMs are releted with force. The bug was fixed
# and will be available in the next release. With a new version of ignite,
# `rm -f` should cleanup everything properly.
sudo "$IGNITE_BIN" stop $(sudo "$IGNITE_BIN" ps -q -a -f "{{.ObjectMeta.Labels}}=~$CLUSTER_LABEL:$CLUSTER_NAME")
sudo "$IGNITE_BIN" rm $(sudo "$IGNITE_BIN" ps -q -a -f "{{.ObjectMeta.Labels}}=~$CLUSTER_LABEL:$CLUSTER_NAME")

echo ""
