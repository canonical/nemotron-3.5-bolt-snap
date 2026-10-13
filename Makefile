SHELL := /bin/bash

.PHONY: all help init build install upload smoke-test install-deps init-submodules download-models download-model-iq2-xxs download-model-dspark-draft download-mmproj

# Always run `hf` via pipx to avoid relying on local `hf` installations.
hf := pipx run --spec "huggingface_hub[cli]" hf

SNAP_NAME ?= nemotron-3-5-bolt

ENGINE ?= cpu

all: help

#
# Main targets
#

help: ## Show this help message
	@echo "Usage: make <target>"
	@echo
	@echo "Targets:"
	@# List all targets with descriptions (lines starting with '##'):
	@grep -E '^[a-zA-Z0-9_-]+:.*## .*$$' $(MAKEFILE_LIST) | \
		sort | \
		awk 'BEGIN {FS = ":.*## "}; {printf "  %-11s %s\n", $$1, $$2}'

init: init-submodules install-deps download-models ## Initialize the build environment (dependencies, model weights, submodules, etc.)

build: ## Build the snap
	./dev/build.sh

install: ## Install the snap
	./dev/install.sh

upload: ## Upload the snap
	./dev/upload.sh

smoke-test: ## Run smoke tests (override with SNAP_NAME=... ENGINE=...)
	sudo ./dev/smoke-test.sh $(SNAP_NAME) $(ENGINE)

#
# Supporting targets
#

install-deps:
	@echo "Installing dependencies..."
	@# Ensure pipx is available for running the hf CLI.
	@command -v pipx >/dev/null 2>&1 || { \
		sudo apt-get update; \
		sudo apt-get install -y pipx; \
	}

init-submodules:
	@echo "Initializing submodules..."
	@if git submodule status | grep -q '^-'; then \
		git submodule update --init; \
	fi

# The model weights are not publicly downloadable yet.
# Place the shards in model-weights/nemotron-3-5-bolt-iq2-xxs-gguf/
# and the draft model in model-weights/nemotron-3-5-bolt-dspark-draft-gguf/ before building.
# TODO: Once published, replace the check with:
#   $(hf) download <org>/<repo> <model-name> --local-dir model-weights/nemotron-3-5-bolt-iq2-xxs-gguf/
download-models: download-model-iq2-xxs download-model-dspark-draft download-mmproj

download-model-iq2-xxs:
	@echo "Checking local Nemotron 3.5 Bolt IQ2_XXS model weights..."
	@for shard in 00001 00002 00003 00004 00005; do \
		file="model-weights/nemotron-3-5-bolt-iq2-xxs-gguf/nemotron-3-5-bolt-iq2-xxs-$$shard-of-00005.gguf"; \
		test -f "$$file" || { echo "Missing shard: $$file"; exit 1; }; \
	done

download-model-dspark-draft:
	@echo "Checking local Nemotron 3.5 Bolt DSpark draft model weights..."
	@ls model-weights/nemotron-3-5-bolt-dspark-draft-gguf/quantized_dspark_n35_bolt_w4a16.gguf >/dev/null 2>&1 || { \
		echo "Missing draft model: place it in model-weights/nemotron-3-5-bolt-dspark-draft-gguf/"; \
		exit 1; \
	}

download-mmproj:
	@echo "Checking local Nemotron 3.5 Bolt mmproj weights..."
	@test -f model-weights/mmproj-74b-a9b-bf16-gguf/mmproj-bf16.gguf || { \
		echo "Missing mmproj: place mmproj-bf16.gguf in model-weights/mmproj-74b-a9b-bf16-gguf/"; \
		exit 1; \
	}
