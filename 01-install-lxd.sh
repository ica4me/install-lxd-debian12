#!/bin/bash
echo "==> Mengunduh paket dasar (Cache Lokal)..."
apt-get update -y
# Opsi -d (--download-only) akan mengunduh paket ke cache tanpa menginstalnya dulu
apt-get install -d -y snapd iptables-persistent curl

echo "==> Menginstal Snap dan paket pendukung..."
apt-get install -y snapd iptables-persistent curl

echo "==> Mengunduh dan Menginstal LXD via Snap..."
snap install core
snap install lxd

echo "==> Menginisialisasi LXD (Default Settings)..."
lxd init --auto

echo "==> MENGUNDUH IMAGE DEBIAN 12 KE LOKAL (Mohon tunggu)..."
# Perintah ini akan mengunduh image ke server lokal Anda dan memberinya nama alias 'debian12-local'
lxc image copy images:debian/12/cloud local: --alias debian12-local

echo "✅ Instalasi LXD & Download Image Selesai."