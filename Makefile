.DEFAULT_GOAL:=help

.PHONY: help

help: ## Display this help.
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n\nTargets:\n"} /^[a-zA-Z0-9_-]+:.*?##/ { printf "  \033[36m%-13s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)

binaries: ## Build kind and ignite binaries.
	bash scripts/build-kind-ignite-binaries.sh

images: ## Build kind base and node image.
	bash scripts/build-kind-images.sh
