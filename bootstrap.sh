#!/usr/bin/env bash

set -euo pipefail

CLUSTER_NAME=utm-cluster
CONTROL_PLANE_IP=192.168.65.2
TALOSCONFIG=./talosconfig
CONTROL_PLANE_YAML=./controlplane.yaml
DISK=/dev/vda

talosctl get disks --insecure --nodes $CONTROL_PLANE_IP

talosctl gen config $CLUSTER_NAME https://$CONTROL_PLANE_IP:6443 --install-disk $DISK --output-dir .

talosctl apply-config --insecure --nodes $CONTROL_PLANE_IP --file $CONTROL_PLANE_YAML

talosctl --talosconfig=$TALOSCONFIG config endpoints $CONTROL_PLANE_IP

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

talosctl kubeconfig . --talosconfig $TALOSCONFIG --endpoints $CONTROL_PLANE_IP --nodes $CONTROL_PLANE_IP

kubectl --kubeconfig kubeconfig get nodes
kubectl --kubeconfig kubeconfig get pods --all-namespaces
