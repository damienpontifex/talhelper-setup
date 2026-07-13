#!/usr/bin/env bash

set -euo pipefail

CONTROL_PLANE_IP=192.168.65.2

talosctl get disks --insecure --nodes $CONTROL_PLANE_IP

# until talosctl --talosconfig=./talosconfig --nodes 192.168.128.2 version &>/dev/null; do
#   echo "Not ready, retry in 5 seconds"
#   sleep 5
# done
#
# talosctl --talosconfig "$TALOSCONFIG" --endpoints "$CONTROL_PLANE_IP" --nodes "$CONTROL_PLANE_IP" health \
#   --wait-timeout 2m \
#   --control-plane-nodes "$CONTROL_PLANE_IP" ||
#   echo "⚠️ Health check timed out (expected before etcd bootstrap). Proceeding..."

# Wait until rebooted
talosctl bootstrap --nodes $CONTROL_PLANE_IP --talosconfig=./talosconfig
