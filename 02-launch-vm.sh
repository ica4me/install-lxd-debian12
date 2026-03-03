#!/bin/bash
CONTAINER_NAME="debian-vm"

echo "==> Membuat profil Cloud-Init LXD..."
lxc profile create debian-cloud 2>/dev/null || true
lxc profile set debian-cloud user.user-data - < user-data

echo "==> Meluncurkan container $CONTAINER_NAME..."
lxc launch local:debian12-local $CONTAINER_NAME --profile default --profile debian-cloud

# ==========================================
# PENGATURAN SPESIFIKASI DINAMIS
# ==========================================
echo "==> Menghitung resource Host yang tersedia..."

# 1. Mendapatkan jumlah core CPU dari 'nproc'
VCPU=$(nproc)

# 2. Mendapatkan total memori dalam MB, lalu dikurangi 250MB untuk Host
TOTAL_MEM_MB=$(free -m | awk '/^Mem:/{print $2}')
VM_MEM_MB=$((TOTAL_MEM_MB - 250))

echo "    -> Alokasi vCPU : $VCPU Core"
echo "    -> Alokasi RAM  : ${VM_MEM_MB}MB (Total Host $TOTAL_MEM_MB MB - 250MB)"
echo "    -> Alokasi Disk : 10GB"

echo "==> Menerapkan limitasi ke container..."
# Set vCPU
lxc config set $CONTAINER_NAME limits.cpu $VCPU

# Set RAM (menggunakan format MB)
lxc config set $CONTAINER_NAME limits.memory ${VM_MEM_MB}MB

# Set Ukuran Disk Root (10GB)
lxc config device override $CONTAINER_NAME root size=10GB
# ==========================================

echo "==> Menunggu container mendapatkan IP (proses Cloud-Init berjalan)..."
sleep 10
CONTAINER_IP=$(lxc list $CONTAINER_NAME -c 4 --format csv | awk '{print $1}')

while [ -z "$CONTAINER_IP" ]; do
    sleep 2
    CONTAINER_IP=$(lxc list $CONTAINER_NAME -c 4 --format csv | awk '{print $1}')
done

echo "✅ Container $CONTAINER_NAME berhasil berjalan di IP: $CONTAINER_IP dengan spek $VCPU vCPU, ${VM_MEM_MB}MB RAM, dan 10GB Disk."
