#!/usr/bin/env bash

set -e

# This script clones kind and ignite repos, builds the binaries and copies them
# to bin/ dir.

# Source the common variables.
source scripts/vars.sh

mkdir -p bin

# Prepare kind repo.
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

# Build kind.
pushd "$KIND_GIT_REPO_DIR"
    echo "Building kind..."
    go version
    GO111MODULE="on" go mod vendor
    GO111MODULE="on" go build -v $KIND_IMPORT_PATH
    cp kind "$BIN_DIR"
popd

# Prepare ignite repo.
if [ ! -d "$IGNITE_GIT_REPO_DIR" ]; then
    # Clone ignite fork.
    echo "Cloning kind repo..."
    git clone --branch "$IGNITE_BRANCH" "$IGNITE_REPO" "$IGNITE_GIT_REPO_DIR" --depth 1
else
    # ignite repo already exists. Add forked repo as a new remote and checkout to
    # kind-essentials branch.
    pushd "$IGNITE_GIT_REPO_DIR"
        echo "kind repo found. Adding forked repo and checking out to ignite branch..."
        if git remote | grep -q -w kind ; then
            echo "found existing remote kind"
        else
            git remote add kind "$IGNITE_REPO"
        fi
        git fetch kind
        if git branch | grep -q -w "$IGNITE_BRANCH" ; then
            echo "found existing branch $IGNITE_BRANCH"
            git checkout "$IGNITE_BRANCH"
        else
            git checkout --track kind/"$IGNITE_BRANCH"
        fi
    popd
fi

# Build ignite.
pushd "$IGNITE_GIT_REPO_DIR"
    echo "Building ignite..."
    make bin/amd64/ignite
    # make ignite
    cp bin/ignite "$BIN_DIR"
popd
