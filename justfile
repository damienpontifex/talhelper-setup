# List all available commands
list:
	just --list

_talosctl command args="":
	@talosctl {{command}} \
		--nodes $(yq '.contexts.homelab.endpoints[0]' ./clusterconfig/talosconfig) \
		--talosconfig=./clusterconfig/talosconfig \
		{{args}}

# Provide a text-based UI to navigate node overview, logs and real-time metrics.
[group("monitoring")]
dashboard:
	@just _talosctl "dashboard"

[group("monitoring")]
health:
	@just _talosctl "health"

gensecrets:
	talhelper gensecret > talsecret.sops.yaml
	sops --encrypt --in-place talsecret.sops.yaml

# Apply a new configuration to a node
[group("dev")]
apply-config: genconfig
	@just _talosctl "apply-config" "--file=./clusterconfig/homelab-homelab-control-01.yaml"

# Generate Talos cluster config YAML files
[group("dev")]
genconfig:
	talhelper genconfig

[group("ops")]
kubeconfig:
	@just _talosctl kubeconfig .

# See if a TCP connection to the node on port 50,000 is possible
[group("monitoring")]
check-connection:
	nc -zv $(yq '.contexts.homelab.endpoints[0]' ./clusterconfig/talosconfig) 50000

[group("maintenance")]
reboot:
	@just _talosctl reboot

apply-cilium:
	kustomize build --enable-helm ~/dev/homelab/apps/01-system-core/cilium/ \
		| kubectl apply --server-side=true --filename - --kubeconfig=./kubeconfig

apply-argocd:
	kustomize build --enable-helm ~/dev/homelab/apps/01-system-core/argocd \
		| kubectl apply --server-side=true --filename - --kubeconfig=./kubeconfig

apply-cloudflare-tunnel:
	# Need tunnel in place so that external secrets can validate the issuer
	kubectl --kubeconfig=./kubeconfig apply --server-side=true --filename ~/dev/homelab/apps/02-core-services/cloudflare-tunnel/namespace.yaml
	# Get the secret manually to bootstrap and external secrets will manage afterwards
	kubectl --kubeconfig=./kubeconfig create secret generic cloudflare-api-token \
		--namespace cloudflare-tunnel \
		--from-literal=token=$(az keyvault secret show --name cloudflare-api-token --vault-name pontifex-homelab --query 'value' --output tsv) || true
	# Apply the role and deployment to make this happen
	kubectl --kubeconfig=./kubeconfig apply --server-side=true --filename ~/dev/homelab/apps/02-core-services/cloudflare-tunnel/jwk-discovery.yaml
	kubectl --kubeconfig=./kubeconfig apply --server-side=true --filename ~/dev/homelab/apps/02-core-services/cloudflare-tunnel/cloudflare-tunnel.yaml

