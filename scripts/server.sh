#!/bin/bash

set -euo pipefail

# Workaround for https://github.com/canonical/inference-snaps/issues/398
read -r uptime _ < /proc/uptime
if (( ${uptime%%.*} < 30 )); then
    echo "System has been up for less than 30 seconds. Waiting for startup to complete..."
    sleep 30
    exit 1
fi

engine="$(modelctl engine --format=json | jq -r .name)"
exec modelctl run --share-provider --fallback-server -- "$SNAP/engines/$engine/server" "$@"
