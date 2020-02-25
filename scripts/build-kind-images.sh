#!/usr/bin/env bash

set -e

# Source the common variables.
source scripts/vars.sh

# k8s repo verison to build the kind node image from.
K8S_REPO_VERSION="${K8S_REPO_VERSION:-master}"
K8S_REPO_DIR="$GOPATH/src/k8s.io/kubernetes"

# rsync is required to build k8s, check if it exists.
if hash rsync 2>/dev/null; then
    echo "rsync found..."
else
    echo "rsync not found. Install rsync and run again."
    exit 1
fi

# Check if k/k already exists.
echo "Preparing k/k repo..."
if [ ! -d "$K8S_REPO_DIR" ]; then
    # Clone k/k.
    echo "Cloning k/k..."
    git clone --branch $K8S_REPO_VERSION https://github.com/kubernetes/kubernetes $GOPATH/src/k8s.io/kubernetes
else
    # k/k repo already exists. Checkout to $K8S_REPO_VERSION tag.
    pushd "$K8S_REPO_DIR"
        echo "k/k repo found. git pull..."
        # TODO: Ensure any changes are not lost. Maybe stash?
        git checkout master
        # git pull
        echo "Checking out ot $K8S_REPO_VERSION..."
        git checkout "$K8S_REPO_VERSION"
    popd
fi
echo ""

# Check if kind repo already exists.
# kind repo is required to build the base image. The base image Dockerfile's
# path points to kind repo.
echo "Preparing kind repo..."
if [ ! -d "$KIND_GIT_REPO_DIR" ]; then
    # Clone kind fork.
    echo "Cloning kind repo..."
    git clone --branch "$KIND_BRANCH" "$KIND_REPO" "$KIND_GIT_REPO_DIR" --depth 1
else
    # kind repo already exists. Add forked repo as a new remote and checkout to
    # ignite-support branch.
    pushd "$KIND_GIT_REPO_DIR"
        echo "kind repo found. Adding forked repo and checking out to ignite branch..."
        if git remote | grep -q -w ignite ; then
            echo "found existing remote ignite"
        else
            git remote add ignite "$KIND_REPO"
        fi

        git fetch ignite
        # Check if the branch already exists.
        if git branch | grep -q -w "$KIND_BRANCH" ; then
            echo "found existing branch $KIND_BRANCH"
            git checkout "$KIND_BRANCH"
        else
            git checkout --track ignite/"$KIND_BRANCH"
        fi
    popd
fi
echo ""

# Build kind.
pushd "$KIND_GIT_REPO_DIR"
    # Check if kind binary exists. Build if not exists.
    if [ ! -f "$KIND_BIN_PATH" ]; then
        echo "Building kind..."
        go build -v "$KIND_IMPORT_PATH"
        cp kind "$BIN_DIR"
    else
        echo "kind binary found..."
    fi

    # Use the kind binary in bin dir to build the images.

    # Build base image using k/k.
    echo "Building base-image..."
    $KIND_BIN_PATH build base-image --ignite=true --image=darkowlzz/base-ignite:100

    # Build node image.
    echo "Building node-image..."
    $KIND_BIN_PATH build node-image --ignite=true --base-image=darkowlzz/base-ignite:100 --image=darkowlzz/node-ignite:100
popd
