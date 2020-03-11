.DEFAULT_GOAL:=help

# Cluster name is the name of the kind cluster. This can be set to different
# names to create multiple kind clusters.
CLUSTER_NAME ?= kind

.PHONY: help clean distclean

help: ## Display this help.
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n\nTargets:\n"} /^[a-zA-Z0-9_-]+:.*?##/ { printf "  \033[36m%-13s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)

binaries: ## Build kind and ignite binaries.
	bash scripts/build-kind-ignite-binaries.sh

images: ## Build kind base and node image.
	bash scripts/build-kind-images.sh

all: ## Build binaries and images.
	bash scripts/build-kind-ignite-binaries.sh
	bash scripts/build-kind-images.sh

cluster: ## Setup a k8s cluster.
	@echo "⚠️  Require root access to setup ignite VMs"
	bash scripts/setup.sh $(CLUSTER_NAME)

clean: ## Delete the k8s cluster.
	@echo "⚠️  Require root access to delete ignite VMs"
	bash scripts/destroy.sh $(CLUSTER_NAME)
	rm -f $(CLUSTER_NAME)-kubeconfig.yaml

deps: ## Install all the system level dependencies for setting up test cluster.
	bash scripts/deps.sh

distclean: ## Delete all the downloaded built files.
	rm -rf bin *-kubeconfig.yaml
