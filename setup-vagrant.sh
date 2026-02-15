#!/usr/bin/env bash
# One-time setup for the Vagrant/libvirt environment.
# Run this once before using run_cc-vagrant.sh.
set -euo pipefail

echo "Installing vagrant..."
sudo pacman -S --needed --noconfirm vagrant libvirt qemu-desktop dnsmasq

echo "Installing vagrant-libvirt plugin..."
vagrant plugin install vagrant-libvirt

echo "Enabling and starting libvirtd..."
sudo systemctl enable --now libvirtd

echo "Adding $USER to libvirt group..."
sudo usermod -aG libvirt "$USER"

echo ""
echo "Setup complete. Log out and back in for the libvirt group to take effect."
