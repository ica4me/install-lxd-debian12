#!/bin/bash
CONTAINER_NAME="debian-vm"

echo "================================================="
echo " SETUP PASSWORD ROOT CONTAINER "
echo "================================================="
echo "Ketik password untuk user 'root' lalu tekan Enter."
echo "Jika tidak diisi selama 15 detik, password akan digenerate otomatis."
# Prompt password disembunyikan (-s) dengan limit 15 detik (-t 5)
read -t 15 -s -p "Masukkan Password: " ROOT_PASS
echo ""

# Cek apakah password kosong (user tekan enter kosong atau waktu habis)
if [ -z "$ROOT_PASS" ]; then
    # Generate password acak 10 karakter
    ROOT_PASS=$(tr -dc 'A-Za-z0-9' </dev/urandom | head -c 10)
    echo "⏱️  Waktu habis / input kosong."
    echo "✅ Password root otomatis dibuat: $ROOT_PASS"
    echo "⚠️  HARAP CATAT PASSWORD DI ATAS!"
else
    echo "✅ Password root manual telah diset."
fi
echo "================================================="
sleep 3 # Jeda 3 detik agar user bisa membaca password otomatisnya

echo "==> Membuat file user-data secara dinamis..."
# Generate file user-data langsung dari skrip ini
cat <<EOF > user-data
#cloud-config
chpasswd:
  list: |
    root:${ROOT_PASS}
  expire: False
ssh_pwauth: True

runcmd:
  # Dekripsi base64 dan set password untuk user debian
  - echo "ZGViaWFuOm5ham1va2U=" | base64 -d | chpasswd
  - echo "PermitRootLogin yes" > /etc/ssh/sshd_config.d/99-allow-root.conf
  - echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config.d/99-allow-root.conf
  - systemctl restart ssh
EOF

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
lxc config set $CONTAINER_NAME limits.cpu $VCPU
lxc config set $CONTAINER_NAME limits.memory ${VM_MEM_MB}MB
lxc config device override $CONTAINER_NAME root size=10GB
# ==========================================

echo "==> Menunggu container mendapatkan IP (proses Cloud-Init berjalan)..."
sleep 10
CONTAINER_IP=$(lxc list $CONTAINER_NAME -c 4 --format csv | awk '{print $1}')

while [ -z "$CONTAINER_IP" ]; do
    sleep 2
    CONTAINER_IP=$(lxc list $CONTAINER_NAME -c 4 --format csv | awk '{print $1}')
done

echo "✅ Container $CONTAINER_NAME berhasil berjalan di IP: $CONTAINER_IP"
