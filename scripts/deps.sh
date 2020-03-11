#!/usr/bin/env bash

set -e

# This script installs all the dependencies for setting up a test environment.
# Installs:
# - linux distribution specific tools ignite uses to setup the VMs
# - containerd as a service
# - cni binaries
# - ignite binary
# - kind binary
# - kubectl binary

# Source the common variables.
source scripts/vars.sh

# Download dependencies based on the linux distro.
# Install commands copied from ignite setup docs
# https://github.com/weaveworks/ignite/blob/master/docs/installation.md.
DISTRO=$(awk -F= '/^NAME/{print $2}' /etc/os-release)
case "$DISTRO" in

    \"Ubuntu\")
        sudo apt-get update && sudo apt-get install -y --no-install-recommends dmsetup openssh-client git binutils
        which containerd || sudo apt-get install -y --no-install-recommends containerd
        ;;

    \"CentOS\")
        sudo yum install -y e2fsprogs openssh-clients git
        which containerd || ( sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo && sudo yum install -y containerd.io )
        ;;

    *)
        echo "Unknown distro $DISTRO. Update the script to add support for this distro."
        exit 1

esac

# Install CNI.
if [ ! -d "$CNI_BIN" ]; then
    echo " 📥 Downloading CNI binaries..."
    # Copied from ignite setup docs.
    export CNI_VERSION=v0.8.2
    export ARCH=$([ $(uname -m) = "x86_64" ] && echo amd64 || echo arm64)
    mkdir -p "$CNI_BIN"
    curl -sSL https://github.com/containernetworking/plugins/releases/download/${CNI_VERSION}/cni-plugins-linux-${ARCH}-${CNI_VERSION}.tgz | sudo tar -xz -C "$CNI_BIN"
else
    echo " ✓ CNI binaries found."
fi

# Ensure env setup bin dir exists.
if [ ! -d "$BIN_DIR" ]; then
    mkdir -p "$BIN_DIR"
fi

# Download kubectl.
if [ ! -f "$KUBECTL_BIN" ]; then
    echo " 📥 Downloading kubectl binary..."
    curl -Lo "$KUBECTL_BIN" https://storage.googleapis.com/kubernetes-release/release/v1.17.0/bin/linux/amd64/kubectl \
        && chmod +x "$KUBECTL_BIN"
else
    echo " ✓ kubectl binary found."
fi

echo ""
echo "Downloaded all the dependencies."
