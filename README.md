# Talos with cluster api

## Bootstrap
1. Download ISO https://factory.talos.dev
    - Bare metal
    - ARM64 on macOS VM using UTM app
    - Download ISO
1. UTM create linux VM from ISO
    - Networking 
        - shared
        - Network card: e1000

1. Bootstrap script

## Bootstrap with talhelper
1. `brew install talhelper`
1. Generate schema for YAML intellisense `mkdir -p .schema && talhelper genschema --file .schema/talconfig.json`
1. Edit [./talhelper.yaml](./talhelper.yaml)
1. `talhelper gensecret > talsecret.sops.yaml`
1. Encrypt the secret with `sops --encrypt --in-place talsecret.sops.yaml`
1. `talhelper genconfig`
1. `talosctl apply-config --insecure --nodes $CONTROL_PLANE_IP --file ./clusterconfig/homelab-homelab-control-01.yaml`
