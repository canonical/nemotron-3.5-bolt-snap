SHELL := /bin/bash

.PHONY: all help init build install upload smoke-test install-deps init-submodules download-models download-model-iq2-xxs download-model-dspark-draft download-mmproj download-model-e4b

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

download-models: download-model-iq2-xxs download-model-dspark-draft download-mmproj download-model-e4b 

download-model-iq2-xxs:
	@echo "Downloading Nemotron 3.5 Bolt IQ2_XXS model weights..."
	$(hf) download inference-snaps/Nemotron-3.5-Bolt-5GB --include "Nemotron-3.5-Bolt-74B-A9B-IQ2_XXS-*-of-00005.gguf" \
		--local-dir model-weights/nemotron-3-5-bolt-iq2-xxs-gguf/

download-model-dspark-draft:
	@echo "Downloading Nemotron 3.5 Bolt DSpark draft model weights..."
	$(hf) download inference-snaps/Nemotron-3.5-Bolt-5GB quantized_dspark_n35_bolt_w4a16.gguf \
		--local-dir model-weights/nemotron-3-5-bolt-dspark-draft-gguf/

download-mmproj:
	@echo "Downloading Nemotron 3.5 Bolt mmproj weights..."
	$(hf) download inference-snaps/Nemotron-3.5-Bolt-5GB mmproj-bf16.gguf \
		--local-dir model-weights/mmproj-74b-a9b-bf16-gguf/

download-model-e4b:
	@echo "Downloading Nemotron 3.5 Bolt E4B model weights..."
	$(hf) download inference-snaps/Nemotron-3.5-Bolt-5GB NVIDIA-Nemotron-3.5-Bolt-E4B-Q4_K_M-00001-of-00002.gguf \
		--local-dir model-weights/nemotron-3-5-bolt-e4b-q4-k-m-gguf/
	$(hf) download inference-snaps/Nemotron-3.5-Bolt-5GB NVIDIA-Nemotron-3.5-Bolt-E4B-Q4_K_M-00002-of-00002.gguf \
		--local-dir model-weights/nemotron-3-5-bolt-e4b-q4-k-m-gguf/

	@echo "Downloading Nemotron 3.5 Bolt E4B mmproj..."
	$(hf) download inference-snaps/Nemotron-3.5-Bolt-5GB NVIDIA-Nemotron-3.5-Bolt-E4B-mmproj-Q8_0.gguf \
		--local-dir model-weights/mmproj-e4b-q8-0/
