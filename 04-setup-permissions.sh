#!/bin/bash

CONTAINER_NAME="debian-vm"

echo "================================================="
echo " MEMBERIKAN AKSES JARINGAN & KERNEL KE CONTAINER "
echo "================================================="

echo "==> [1/4] Menghentikan sementara container $CONTAINER_NAME..."
lxc stop $CONTAINER_NAME

echo "==> [2/4] Meneruskan perangkat /dev/net/tun ke dalam container..."
# Menggunakan '|| true' agar skrip tidak error jika perangkat tun sudah pernah ditambahkan sebelumnya
lxc config device add $CONTAINER_NAME tun unix-char path=/dev/net/tun 2>/dev/null || true

echo "==> [3/4] Memberikan hak akses Privileged dan Nesting..."
lxc config set $CONTAINER_NAME security.nesting true
lxc config set $CONTAINER_NAME security.privileged true

echo "==> [4/4] Mengizinkan akses modul kernel (iptables, nat, tun, wireguard)..."
lxc config set $CONTAINER_NAME linux.kernel_modules ip_tables,ip6_tables,netlink_diag,nf_nat,tun,wireguard

echo "==> Menyalakan kembali container $CONTAINER_NAME..."
lxc start $CONTAINER_NAME

echo "Menunggu container siap..."
sleep 5

CONTAINER_STATE=$(lxc list $CONTAINER_NAME -c s --format csv)
if [ "$CONTAINER_STATE" == "RUNNING" ]; then
    echo "✅ Konfigurasi berhasil! Container sudah menyala dengan hak akses penuh."
else
    echo "❌ Gagal menyalakan container. Silakan cek status dengan 'lxc info $CONTAINER_NAME'."
fi
echo "================================================="
