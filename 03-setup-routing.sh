#!/bin/bash
CONTAINER_NAME="debian-vm"

echo "==> [1/4] Mengatur Port SSH Host ke 2026..."
sed -i 's/^#*Port 22/Port 2026/' /etc/ssh/sshd_config
if ! grep -q "^Port 2026" /etc/ssh/sshd_config; then
    echo "Port 2026" >> /etc/ssh/sshd_config
fi
systemctl restart ssh || systemctl restart sshd

echo "==> [2/4] Mendeteksi interface utama dan IP Container..."
MAIN_IFACE=$(ip route show default | awk '/default/ {print $5}' | head -1)
CONTAINER_IP=$(lxc list $CONTAINER_NAME -c 4 --format csv | awk '{print $1}')

if [ -z "$MAIN_IFACE" ] || [ -z "$CONTAINER_IP" ]; then
    echo "❌ Gagal mendeteksi Interface Host atau IP Container! Pastikan container sudah berjalan."
    exit 1
fi
echo "Interface: $MAIN_IFACE | IP Container: $CONTAINER_IP"

echo "==> [3/4] Menerapkan aturan iptables (NAT DMZ ke Container)..."
# Mengaktifkan IP Forwarding
sysctl -w net.ipv4.ip_forward=1 > /dev/null
echo "net.ipv4.ip_forward=1" > /etc/sysctl.d/99-ipforward.conf
sysctl -p /etc/sysctl.d/99-ipforward.conf > /dev/null

# Hapus aturan NAT lama agar tidak bertumpuk
iptables -t nat -F PREROUTING

# Belokkan SEMUA trafik TCP (kecuali port 2026) ke IP Container
iptables -t nat -A PREROUTING -i $MAIN_IFACE -p tcp ! --dport 2026 -j DNAT --to-destination $CONTAINER_IP

# Belokkan SEMUA trafik UDP ke IP Container
iptables -t nat -A PREROUTING -i $MAIN_IFACE -p udp -j DNAT --to-destination $CONTAINER_IP

# Atur Masquerade untuk akses internet dari container keluar
iptables -t nat -C POSTROUTING -s $CONTAINER_IP -o $MAIN_IFACE -j MASQUERADE 2>/dev/null || iptables -t nat -A POSTROUTING -s $CONTAINER_IP -o $MAIN_IFACE -j MASQUERADE

echo "==> [4/4] Menyimpan konfigurasi iptables permanen..."
netfilter-persistent save > /dev/null

PUBLIC_IP=$(curl -s -4 ifconfig.me)
echo "================================================="
echo " SETUP SELESAI! "
echo "================================================="
echo "Akses SSH ke CONTAINER: ssh root@$PUBLIC_IP"
echo "Akses SSH ke HOST     : ssh root@$PUBLIC_IP -p 2026"
echo "================================================="
