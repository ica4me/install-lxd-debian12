#!/bin/bash
#Hapus semuanya: 
# Skrip purge ini akan menghapus permanen container beserta datanya, 
# mencabut LXD dari sistem operasi, dan membersihkan aturan Iptables.

echo "================================================="
echo " MEMULAI PROSES PURGE LXD & CONTAINER "
echo "================================================="

echo "==> [1/4] Menghapus container debian-vm..."
lxc delete debian-vm --force 2>/dev/null || true

echo "==> [2/4] Menghapus profile cloud-init..."
lxc profile delete debian-cloud 2>/dev/null || true

echo "==> [3/4] Menghapus aturan iptables NAT..."
iptables -t nat -F PREROUTING
iptables -t nat -F POSTROUTING
netfilter-persistent save > /dev/null

echo "==> [4/4] Menghapus sistem LXD secara menyeluruh (Snap purge)..."
snap remove lxd --purge

echo "================================================="
echo "✅ SELESAI! Penyimpanan Host telah kembali lega."
echo "⚠️  Catatan: Port SSH Host Anda masih berada di 2026."
echo "   Untuk mengembalikan ke port 22, edit /etc/ssh/sshd_config"
echo "   lalu jalankan: systemctl restart ssh"
echo "================================================="