# Install Debian 12 Generic Cloud di LXD Container

Repositori ini berisi kumpulan skrip otomatis untuk menginstal dan menjalankan **Debian 12 Generic Cloud** di dalam **LXD Container**.

Skrip ini ditujukan untuk dijalankan pada **Host Linux (Debian/Ubuntu)** dan sudah dioptimalkan untuk kebutuhan akses penuh (_privileged_, modul kernel, perangkat TUN). Cocok untuk menjalankan layanan VPN / tunneling server (mis. Xray, OpenVPN, BadVPN, dan sejenisnya).

---

## Prasyarat

- Anda **login sebagai `root`** pada VPS/Server Host sebelum memulai.
- Host OS: **Debian atau Ubuntu**.
- Akses internet pada host (untuk instalasi paket dan image).

---

## 🚀 Cara Instalasi

### 0) Siapkan direktori kerja

```bash
apt-get update && apt-get install -y wget git curl
```

```bash
rm -f /etc/resolv.conf
echo "nameserver 8.8.8.8" > /etc/resolv.conf
echo "nameserver 1.1.1.1" >> /etc/resolv.conf
systemctl restart systemd-resolved 2>/dev/null || systemctl restart networking 2>/dev/null
```

### 1) Siapkan direktori kerja

```bash
mkdir -p /root/lxd-deployment
cd /root/lxd-deployment
```

### 2) Clone repositori

```bash
git clone https://github.com/ica4me/install-lxd-debian12.git .
```

### 3) Beri izin eksekusi pada skrip

```bash
chmod +x   01-install-lxd.sh   02-launch-vm.sh   03-setup-routing.sh   04-setup-permissions.sh   99-purge-all.sh
```

### 4) Jalankan skrip secara berurutan

```bash
./01-install-lxd.sh
./02-launch-vm.sh
./03-setup-routing.sh
./04-setup-permissions.sh
```

### 5) Longgarkan Limit RAM Container (Mengatasi OOM Killer)

Setting ini di host bukan vm lxd

Buat Swap

```bash
wget https://raw.githubusercontent.com/ica4me/auto-script-free/main/make-swap.sh && chmod +x make-swap.sh && bash make-swap.sh
```

Menghapus batasan RAM kaku

```bash
lxc config unset debian-vm limits.memory
```

Mengizinkan container memakai memori Swap host tanpa batas

```bash
lxc config set debian-vm limits.memory.swap true
```

---

## 💻 Akses & Manajemen

Setelah instalasi selesai:

- Port SSH standar Host (**22**) akan dipindahkan ke **2026**.
- Trafik internet publik akan dibelokkan langsung ke container (mode **DMZ**).

> **Catatan penting:** Pastikan Anda sudah menguji akses ke Host via port **2026** sebelum menutup sesi saat ini, agar tidak terkunci dari server.

---

## Masuk ke Container

### 1) Shell langsung (paling cepat)

```bash
lxc exec debian-vm -- bash
```

Install SSH agar bisa di remot

```bash
apt update && apt install -y openssh-server

#echo "root:xapapa" | chpasswd
echo "PermitRootLogin yes" > /etc/ssh/sshd_config.d/99-allow-root.conf
echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config.d/99-allow-root.conf

systemctl restart ssh
systemctl status ssh
```

### 2) Console TTY (seperti monitor fisik)

```bash
lxc console debian-vm
```

Untuk keluar dari TTY: tekan `Ctrl + a`, lepaskan, lalu tekan `q`.

### 3) SSH dari luar (internet)

```bash
ssh root@<IP_PUBLIC_HOST>
```

Gunakan password default yang ada di file `user-data`.

---

## Akses ke OS Host

Karena port 22 sudah diteruskan ke container, gunakan port **2026** untuk mengakses Host:

```bash
ssh root@<IP_PUBLIC_HOST> -p 2026
```

---

## Kontrol Container

### Menghentikan container

```bash
lxc stop debian-vm
```

### Menghapus container saja

```bash
lxc delete debian-vm --force
```

---

## 🗑️ Uninstall & Purge (Hapus Bersih)

Untuk menghapus seluruh environment LXD, membebaskan ruang penyimpanan Host, serta menghapus aturan routing yang dibuat, jalankan:

```bash
./99-purge-all.sh
```

## FIX ERROR HOST lxc: command not found

```bash
./fix-host-error.sh
```

**Catatan:**

- Skrip purge akan menghapus container beserta datanya, mencabut LXD dari sistem, dan membersihkan aturan iptables.
- Port SSH Host akan **tetap** berada di **2026**. Jika ingin mengembalikannya, ubah `/etc/ssh/sshd_config` secara manual dan restart SSH.
