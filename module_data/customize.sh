##########################################################################################
# Config Flags
##########################################################################################

# We use custom unzipping
SKIPUNZIP=1

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

ui_print "*******************************"
ui_print "      OpenSSH for Android      "
ui_print "*******************************"

local TMPDIR="$MODPATH/tmp"
ui_print "[0/7] Preparing module directory"
mkdir -p "$TMPDIR"
mkdir -p "$MODPATH/bin"
mkdir -p "$MODPATH/lib"

ui_print "[1/7] Extracting architecture unspecific module files"
unzip -o "$ZIPFILE" 'common/opensshd.init' -d "$TMPDIR" >&2
mv "$TMPDIR/common/opensshd.init" "$MODPATH"

ui_print "[2/7] Extracting libraries and binaries for $ARCH"
unzip -o "$ZIPFILE" "arch/$ARCH/*" -d "$TMPDIR" >&2
mv "$TMPDIR/arch/$ARCH/lib"/* "$MODPATH/lib"
mv "$TMPDIR/arch/$ARCH/bin"/* "$MODPATH/bin"

ui_print "[3/7] Creating symlinks"
rm -rf "$MODPATH/system/$BIN_DIR"
rm -rf "$MODPATH/system/$LIB_DIR"
mkdir -p "$MODPATH/system/$BIN_DIR"
mkdir -p "$MODPATH/system/$LIB_DIR"

for f in scp sftp sftp-server ssh ssh-keygen sshd rsync autossh; do
  ln -s $MODPATH/bin/$f "$MODPATH/system/$BIN_DIR/$f"
done
ln -s $MODPATH/lib/libcrypto.so.1.1 "$MODPATH/system/$LIB_DIR/libcrypto.so"

ui_print "[4/7] Creating SSH user directories"
mkdir -p /data/ssh
mkdir -p /data/ssh/root/.ssh
mkdir -p /data/ssh/shell/.ssh

if [ -f /data/ssh/sshd_config ]; then
  ui_print "[5/7] Found sshd_config, will not copy a default one"
else
  ui_print "[5/7] Extracting sshd_config"
  unzip -o "$ZIPFILE" 'common/sshd_config' -d "$TMPDIR" >&2
  mv "$TMPDIR/common/sshd_config" '/data/ssh/'
fi

ui_print "[6/7] Setting permissions"
set_perm_recursive $MODPATH 0 0 0755 0644
set_perm_recursive "$MODPATH/system/" 0 0 0755 0755
set_perm "$MODPATH/opensshd.init" 0 0 0755
set_perm /data/ssh/sshd_config 0 0 0600
chown shell:shell /data/ssh/shell
chown shell:shell /data/ssh/shell/.ssh
chown root:root /data/ssh/root
chown root:root /data/ssh/root/.ssh
chmod 700 /data/ssh/{shell,root}/.ssh

ui_print "[7/7] Cleaning up"
rm -rf "$TMPDIR"