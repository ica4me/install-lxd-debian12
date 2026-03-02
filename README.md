# Install Debian 12 LXD Container (Generic Cloud)

Repositori ini berisi kumpulan skrip otomatis untuk menginstal dan menjalankan **Debian 12 Generic Cloud** di dalam **LXD Container**.

Skrip ini dirancang untuk dijalankan pada **Host Linux (Debian atau Ubuntu)** dan sudah dioptimalkan dengan hak akses penuh (_privileged_, modul kernel, perangkat TUN) sehingga sangat cocok untuk menjalankan layanan VPN / Tunneling Server (seperti Xray, OpenVPN, BadVPN, dll).

---

## 🚀 Cara Instalasi

Pastikan Anda login sebagai `root` di VPS / Server Host Anda sebelum memulai.

**1. Buat direktori kerja dan masuk ke dalamnya:**
\`\`\`bash
mkdir -p /root/lxd-deployment
cd /root/lxd-deployment
\`\`\`

**2. Clone repositori ini ke dalam direktori tersebut:**
\`\`\`bash
git clone https://github.com/ica4me/install-lxd-debian12.git .
\`\`\`

**3. Berikan izin eksekusi pada semua skrip:**
\`\`\`bash
chmod +x 01-install-lxd.sh 02-launch-vm.sh 03-setup-routing.sh 04-setup-permissions.sh 99-purge-all.sh
\`\`\`

**4. Eksekusi skrip secara berurutan:**
\`\`\`bash
./01-install-lxd.sh
./02-launch-vm.sh
./03-setup-routing.sh
./04-setup-permissions.sh
\`\`\`

---

## 💻 Panduan Akses & Manajemen

Setelah proses instalasi selesai, port SSH standar (22) milik Host akan dipindah ke `2026`, dan semua trafik internet publik akan dibelokkan langsung ke dalam Container (Mode DMZ).

### Masuk ke Container (VM)

- **Masuk via Shell Langsung (Paling Cepat & Mudah):**
  \`\`\`bash
  lxc exec debian-vm -- bash
  \`\`\`
- **Masuk via Console TTY (Seperti layar monitor fisik):**
  \`\`\`bash
  lxc console debian-vm
  \`\`\`
  _(Untuk keluar dari TTY: tekan `Ctrl + a`, lepaskan, lalu tekan `q`)_
- **Akses SSH dari Luar (Internet):**
  \`\`\`bash
  ssh root@<IP_PUBLIC_HOST>
  \`\`\`
  _(Gunakan password default yang ada di file `user-data`)_

### Akses ke OS Host

Karena port 22 sudah diteruskan ke container, Anda harus menggunakan port 2026 untuk meremote Host.
\`\`\`bash
ssh root@<IP_PUBLIC_HOST> -p 2026
\`\`\`

### Kontrol Container

- **Menghentikan Container:**
  \`\`\`bash
  lxc stop debian-vm
  \`\`\`
- **Menghapus Container Saja:**
  \`\`\`bash
  lxc delete debian-vm --force
  \`\`\`

---

## 🗑️ Uninstall & Purge (Hapus Bersih)

Jika Anda ingin menghapus seluruh _environment_ LXD, membebaskan kembali ruang penyimpanan Host, dan menghapus aturan _routing_ yang sudah dibuat, jalankan skrip _purge_ berikut:

\`\`\`bash
./99-purge-all.sh
\`\`\`

**Catatan:** Skrip _purge_ ini akan menghapus permanen container beserta datanya, mencabut LXD dari sistem operasi, dan membersihkan aturan Iptables. Port SSH Host akan tetap berada di `2026`, Anda dapat mengembalikannya secara manual di `/etc/ssh/sshd_config` jika diperlukan.
