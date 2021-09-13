#!/system/bin/sh

MODPATH=${0%/*}

if [ -d "/system/xbin" ]; then
  BIN_DIR="xbin"
else
  BIN_DIR="bin"
fi

rm -rf "$MODPATH/system"
mkdir -p "$MODPATH/system/$BIN_DIR"

for f in scp sftp sftp-server ssh ssh-keygen sshd; do
  ln -s $MODPATH/bin/magisk_ssh_library_wrapper "$MODPATH/system/$BIN_DIR/$f"
done
for f in rsync autossh openssl; do
  ln -s $MODPATH/bin/$f "$MODPATH/system/$BIN_DIR/$f"
done
ln -s $MODPATH/lib/libcrypto.so.1.1 "$MODPATH/lib/libcrypto.so"

set_perm_recursive "$MODPATH/system/" 0 0 0755 0755

# Update launcher
/data/adb/magisk/busybox sed -i 's|bindir=|bindir='$MODPATH'/bin|g' $MODPATH/bin/magisk_ssh_library_wrapper
/data/adb/magisk/busybox sed -i 's|libdir=|libdir='$MODPATH'/lib|g' $MODPATH/bin/magisk_ssh_library_wrapper

# Update opensshd.init
/data/adb/magisk/busybox sed -i 's|prefix="$MODDIR/system"|prefix="/system"|g' $MODPATH/opensshd.init
/data/adb/magisk/busybox sed -i 's|SSHD=$prefix/bin/sshd|SSHD=$prefix/'$BIN_DIR'/sshd|g' $MODPATH/opensshd.init
/data/adb/magisk/busybox sed -i 's|SSH_KEYGEN=$prefix/bin/ssh-keygen|SSH_KEYGEN=$prefix/'$BIN_DIR'/ssh-keygen|g' $MODPATH/opensshd.init

rm -f "$MODPATH/post-fs-data.sh"