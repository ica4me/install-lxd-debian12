#!/bin/bash
# Skrip purge ini akan menghapus permanen container beserta datanya, 
# membersihkan aturan Iptables, dan menghapus cache paket yang diunduh.

echo "================================================="
echo " MEMULAI PROSES PURGE LXD & CONTAINER "
echo "================================================="

# Pertanyaan konfirmasi hapus image (Default: N/Tidak)
read -p "Apakah Anda ingin menghapus Image LXD (Debian 12) juga? [y/N]: " hapus_image
# Jika ditekan Enter saja, variabel akan otomatis bernilai N
hapus_image=${hapus_image:-N}

echo "==> [1/5] Menghapus container debian-vm..."
lxc delete debian-vm --force 2>/dev/null || true

echo "==> [2/5] Menghapus profile cloud-init..."
lxc profile delete debian-cloud 2>/dev/null || true

echo "==> [3/5] Menghapus aturan iptables NAT..."
iptables -t nat -F PREROUTING
iptables -t nat -F POSTROUTING
netfilter-persistent save > /dev/null

echo "==> [4/5] Menghapus cache paket unduhan (APT)..."
# Menghapus file .deb yang diunduh ke /var/cache/apt/archives/
apt-get clean
echo "Cache paket berhasil dibersihkan."

# Logika penghapusan Image & LXD
if [[ "$hapus_image" =~ ^[Yy]$ ]]; then
    echo "==> [5/5] Menghapus Image dan sistem LXD secara menyeluruh (Snap purge)..."
    snap remove lxd --purge
else
    echo "==> [5/5] Mempertahankan Image... Sistem LXD tidak di-uninstall agar image tetap tersimpan."
fi

echo "================================================="
echo "✅ SELESAI! Proses pembersihan telah berhasil."
echo "⚠️  Catatan: Port SSH Host Anda masih berada di 2026."
echo "   Untuk mengembalikan ke port 22, edit /etc/ssh/sshd_config"
echo "   lalu jalankan: systemctl restart ssh"
echo "================================================="