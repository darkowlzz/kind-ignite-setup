#!/usr/bin/env bash

set -e

BIN_DIR="$PWD/bin"
# Some CI environments have multiple paths in the GOPATH variables. Use the
# first path only.
BUILD_GOPATH="${GOPATH%%:*}"

KIND_REPO="${KIND_REPO:-https://github.com/darkowlzz/kind}"
KIND_BRANCH="${KIND_BRANCH:-ignite-support-storageos-images-1.19}"
KIND_IMPORT_PATH=sigs.k8s.io/kind
KIND_GIT_REPO_DIR="$BUILD_GOPATH/src/$KIND_IMPORT_PATH"
KIND_BIN_PATH="$BIN_DIR/kind"

IGNITE_REPO="${IGNITE_REPO:-https://github.com/darkowlzz/ignite}"
IGNITE_BRANCH="${IGNITE_BRANCH:-kind-essentials}"
IGNITE_IMPORT_PATH=github.com/weaveworks/ignite
IGNITE_GIT_REPO_DIR="$BUILD_GOPATH/src/$IGNITE_IMPORT_PATH"
IGNITE_BIN_PATH="$BIN_DIR/ignite"
