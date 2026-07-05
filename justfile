# List all available commands
list:
	just --list

_talosctl command args="":
	@talosctl {{command}} \
		--nodes $(yq '.nodes[0].ipAddress' talconfig.yaml) \
		--talosconfig=./clusterconfig/talosconfig \
		{{args}}

# Provide a text-based UI to navigate node overview, logs and real-time metrics.
[group("monitoring")]
dashboard:
	@just _talosctl "dashboard"

[group("monitoring")]
health:
	@just _talosctl "health"

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
	nc -zv $(yq '.nodes[0].ipAddress' talconfig.yaml) 50000

[group("maintenance")]
reboot:
	@just _talosctl reboot
