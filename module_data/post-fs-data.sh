#!/system/bin/sh

MODPATH=${0%/*}

if [ -d "/system/xbin" ]; then
  BIN_DIR="xbin"
else
  BIN_DIR="bin"
fi

if [ -d "/system/lib64" ]; then
  LIB_DIR="lib64"
else
  LIB_DIR="lib"
fi

rm -rf "$MODPATH/system"
mkdir -p "$MODPATH/system/$BIN_DIR"
mkdir -p "$MODPATH/system/$LIB_DIR"

for f in scp sftp sftp-server ssh ssh-keygen sshd rsync autossh openssl; do
  ln -s $MODPATH/bin/$f "$MODPATH/system/$BIN_DIR/$f"
done

for f in libcrypto.so.1.1 libssl.so.1.1; do
  ln -s $MODPATH/lib/$f "$MODPATH/system/$LIB_DIR/$f"
done

set_perm_recursive "$MODPATH/system/" 0 0 0755 0755

# Update opensshd.init
/data/adb/magisk/busybox sed -i 's|prefix="$MODDIR/system"|prefix="/system"|g' $MODPATH/opensshd.init
/data/adb/magisk/busybox sed -i 's|SSHD=$prefix/bin/sshd|SSHD=$prefix/'$BIN_DIR'/sshd|g' $MODPATH/opensshd.init
/data/adb/magisk/busybox sed -i 's|SSH_KEYGEN=$prefix/bin/ssh-keygen|SSH_KEYGEN=$prefix/'$BIN_DIR'/ssh-keygen|g' $MODPATH/opensshd.init

rm -f "$MODPATH/post-fs-data.sh"