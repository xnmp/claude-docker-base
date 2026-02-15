#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BRIDGE="virbr1"
SUBNET="192.168.121.0/24"

# Always sync Vagrantfile from source
cp "$SCRIPT_DIR/Vagrantfile" Vagrantfile

# Ensure NAT and forwarding rules exist for the VM subnet.
# Docker sets iptables FORWARD policy to DROP, blocking VM traffic.
# These rules are idempotent and non-persistent (lost on reboot).
if ! sudo nft list table ip nat 2>/dev/null | grep -q "$SUBNET"; then
    sudo nft add table ip nat 2>/dev/null || true
    sudo nft add chain ip nat postrouting '{ type nat hook postrouting priority 100; }' 2>/dev/null || true
    sudo nft add rule ip nat postrouting ip saddr "$SUBNET" masquerade
fi
if ! sudo iptables -C FORWARD -i "$BRIDGE" -j ACCEPT 2>/dev/null; then
    sudo iptables -I FORWARD 1 -i "$BRIDGE" -j ACCEPT
fi
if ! sudo iptables -C FORWARD -o "$BRIDGE" -m state --state RELATED,ESTABLISHED -j ACCEPT 2>/dev/null; then
    sudo iptables -I FORWARD 1 -o "$BRIDGE" -m state --state RELATED,ESTABLISHED -j ACCEPT
fi

vagrant up

# Use direct SSH — vagrant ssh swallows stdout on some libvirt setups.
SSH_CONFIG=$(vagrant ssh-config 2>/dev/null | grep -v '^\[')
exec ssh -t \
    -o StrictHostKeyChecking=no \
    -o UserKnownHostsFile=/dev/null \
    -o LogLevel=ERROR \
    -i "$(echo "$SSH_CONFIG" | awk '/IdentityFile/ {print $2}')" \
    -p "$(echo "$SSH_CONFIG" | awk '/Port / {print $2}')" \
    vagrant@"$(echo "$SSH_CONFIG" | awk '/HostName/ {print $2}')" \
    "cd /agent-workspace && claude --dangerously-skip-permissions"
