#!/bin/sh
# install.sh -- set up an lsd-cluster with one command (Linux, macOS)
#
#   curl -fsSL https://raw.githubusercontent.com/Fran6nd/lsd-cluster/main/install.sh | sh
#
# Starts the cluster's container -- a Docker engine of its own that the
# lsd-docker instances run inside -- and installs `lsdc` on PATH, a
# short alias for `docker exec -it lsd-cluster lsdc`. Everything it does
# is a docker command, printed as it goes.
#
# Environment: LSDC_IMAGE_CLUSTER, LSDC_NAME (container), LSDC_VOLUME,
# LSDC_PORTS (the UDP ports instances may use: 32887-32906).
set -eu

IMAGE=${LSDC_IMAGE_CLUSTER:-ghcr.io/fran6nd/lsd-cluster:latest}
NAME=${LSDC_NAME:-lsd-cluster}
VOLUME=${LSDC_VOLUME:-lsd-cluster}
PORTS=${LSDC_PORTS:-32887-32906}

say() { printf '%s\n' "$*"; }
run() { say "+ $*"; "$@"; }

command -v docker >/dev/null 2>&1 || {
	say "docker is not installed: https://docs.docker.com/engine/install/"
	exit 1
}
echo "$PORTS" | grep -Eq '^[0-9]+-[0-9]+$' || { say "LSDC_PORTS=$PORTS: write it first-last, like 32887-32906"; exit 1; }

if docker container inspect "$NAME" >/dev/null 2>&1; then
	say "a container named $NAME already exists: docker exec -it $NAME lsdc ls"
	exit 1
fi

# This host's LAN addresses, for the connect addresses the instances
# print: a container cannot see them itself.
host_addresses() {
	if command -v ip >/dev/null 2>&1; then
		ip -4 -o addr show scope global \
			| awk '$2 !~ /^(docker|br-|veth|virbr|cni|flannel|tailscale|wg|tun)/ {split($4, a, "/"); print a[1]}'
	elif command -v ifconfig >/dev/null 2>&1; then
		ifconfig | awk '/^[a-z]/ {iface = $1} /inet / && $2 != "127.0.0.1" && iface ~ /^(en|eth|wl)/ {print $2}'
	fi | tr '\n' ' ' | sed 's/ *$//'
}
ADDRESSES=$(host_addresses)

run docker pull "$IMAGE"
run docker volume create "$VOLUME" >/dev/null
# --privileged: an engine inside a container needs it.
run docker run -d --name "$NAME" --privileged --restart unless-stopped \
	-p "$PORTS:$PORTS/udp" -e LSDC_PORTS="$PORTS" -e LSD_HOST_ADDRESSES="$ADDRESSES" \
	-v "$VOLUME:/var/lib/docker" "$IMAGE" >/dev/null

# The alias, where there is somewhere on PATH to put it.
# shellcheck disable=SC2016
wrapper='#!/bin/sh
# lsdc -- shorthand for docker exec '"$NAME"' lsdc
if [ -t 0 ]; then exec docker exec -it '"$NAME"' lsdc "$@"; fi
exec docker exec -i '"$NAME"' lsdc "$@"'
for dir in /usr/local/bin "$HOME/.local/bin"; do
	if [ -d "$dir" ] && [ -w "$dir" ]; then
		printf '%s\n' "$wrapper" > "$dir/lsdc" && chmod +x "$dir/lsdc"
		say "installed $dir/lsdc"
		break
	fi
done

say ""
say "The cluster is starting; ports $PORTS/udp are its instances'."
say "  a server:    lsdc new <name>          (docker exec -it $NAME lsdc new <name>)"
say "  all of them: lsdc ls"
say "  everything:  lsdc help"
