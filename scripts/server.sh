#!/bin/bash

set -euo pipefail

read -r uptime _ < /proc/uptime
uptime_seconds=${uptime%%.*}
if (( uptime_seconds < 30 )); then
    echo "The system has been up for $(uptime_seconds) seconds. Wait for 30 seconds uptime before starting the service."
    echo "This is a temporary workaround for https://github.com/canonical/inference-snaps/issues/398"
    sleep $((30 - uptime_seconds))
    exit 1
fi

engine="$(modelctl engine --format=json | jq -r .name)"
exec modelctl run --share-provider --fallback-server -- "$SNAP/engines/$engine/server" "$@"
