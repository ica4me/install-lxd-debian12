#!/bin/bash
echo "==> Menginstal Snap dan LXD..."
apt-get update -y
apt-get install -y snapd iptables-persistent curl
snap install core
snap install lxd

echo "==> Menginisialisasi LXD (Default Settings)..."
lxd init --auto

echo "✅ Instalasi LXD Selesai."
