#!/bin/bash

CONTAINER_NAME="debian-vm"
SHORTCUT_PATH="/usr/local/sbin/vm"

echo "================================================="
echo " MEMBUAT SHORTCUT CONSOLE CONTAINER "
echo "================================================="

echo "==> [1/2] Membuat file eksekusi di $SHORTCUT_PATH..."
cat << 'INNER_EOF' > $SHORTCUT_PATH
#!/bin/bash
# Shortcut untuk masuk ke dalam container lxd
lxc exec debian-vm -- bash
INNER_EOF

echo "==> [2/2] Memberikan izin eksekusi (chmod +x)..."
chmod +x $SHORTCUT_PATH

echo "================================================="
echo "✅ Shortcut berhasil dibuat!"
echo "Sekarang Anda hanya perlu mengetik perintah:"
echo "   vm"
echo "di terminal Host untuk langsung masuk ke dalam container $CONTAINER_NAME."
echo "================================================="