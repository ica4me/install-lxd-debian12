#!/bin/bash
echo "================================================="
echo "==> [1/4] Menginstal Snap dan LXD..."
apt-get update -y
apt-get install -y snapd iptables-persistent curl wget
snap install core
snap install lxd

echo "==> [2/4] Menginisialisasi LXD (Default Settings)..."
lxd init --auto

echo "==> [3/4] Mendownload Image Custom Debian 12 (Fast Download)..."
# Mengunduh langsung dari server pribadi Anda
wget -O debian-12-custom https://file.meiyu.my.id/debian-12-custom
wget -O debian-12-custom.root https://file.meiyu.my.id/debian-12-custom.root

echo "==> [4/4] Mengimport Image ke LXD lokal..."
lxc image import debian-12-custom debian-12-custom.root --alias debian12-local

echo "==> Membersihkan file mentahan..."
rm -f debian-12-custom debian-12-custom.root

echo "================================================="
echo "✅ Instalasi LXD & Import Image Selesai."
echo "Image siap digunakan!"