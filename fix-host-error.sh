#!/bin/bash

# 1. Matikan semua proses swap yang sedang aktif di sistem
swapoff -a

# 2. (Opsional/Pastikan) Matikan spesifik swapfile milik container tersebut jika masih nyangkut
swapoff /var/snap/lxd/common/lxd/storage-pools/default/containers/debian-vm/rootfs/swapfile 2>/dev/null || true

# 3. Hapus paksa file swap tersebut
rm -f /var/snap/lxd/common/lxd/storage-pools/default/containers/debian-vm/rootfs/swapfile

# 4. Sekarang, ulangi proses Purge (pasti berhasil karena file swap sudah hilang)
snap remove lxd --purge

# 5. Instal kembali LXD dengan bersih
snap install lxd

# 6. Terapkan Environment Path
source /etc/profile
export PATH=$PATH:/snap/bin

# 7. Cek versi untuk verifikasi
echo "================================================="
echo "VERIFIKASI INSTALASI LXD:"
lxc --version
lxd --version
echo "================================================="