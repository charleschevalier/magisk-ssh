##########################################################################################
# Config Flags
##########################################################################################

# We use custom unzipping
SKIPUNZIP=1

ui_print "*******************************"
ui_print "      OpenSSH for Android      "
ui_print "*******************************"

local TMPDIR="$MODPATH/tmp"
ui_print "[0/6] Preparing module directory"
mkdir -p "$TMPDIR"
mkdir -p "$MODPATH/bin"
mkdir -p "$MODPATH/lib"

ui_print "[1/6] Extracting architecture unspecific module files"
unzip -o "$ZIPFILE" 'common/opensshd.init' -d "$TMPDIR"
unzip -o "$ZIPFILE" 'common/magisk_ssh_library_wrapper' -d "$TMPDIR"
unzip -o "$ZIPFILE" 'common/service.sh' -d "$TMPDIR"
unzip -o "$ZIPFILE" 'post-fs-data.sh' -d "$TMPDIR"
mv "$TMPDIR/common/opensshd.init" "$MODPATH"
mv "$TMPDIR/common/service.sh" "$MODPATH"
mv "$TMPDIR/common/magisk_ssh_library_wrapper" "$MODPATH/bin"
mv "$TMPDIR/post-fs-data.sh" "$MODPATH"

ui_print "[2/6] Extracting libraries and binaries for $ARCH"
unzip -o "$ZIPFILE" "arch/$ARCH/*" -d "$TMPDIR"
mv "$TMPDIR/arch/$ARCH/lib"/* "$MODPATH/lib"
mv "$TMPDIR/arch/$ARCH/bin"/* "$MODPATH/bin"

ui_print "[3/6] Creating SSH user directories"
mkdir -p /data/ssh
mkdir -p /data/ssh/root/.ssh
mkdir -p /data/ssh/shell/.ssh

if [ -f /data/ssh/sshd_config ]; then
  ui_print "[4/6] Found sshd_config, will not copy a default one"
else
  ui_print "[4/6] Extracting sshd_config"
  unzip -o "$ZIPFILE" 'common/sshd_config' -d "$TMPDIR"
  mv "$TMPDIR/common/sshd_config" '/data/ssh/'
fi

ui_print "[5/6] Setting permissions"
set_perm_recursive $MODPATH 0 0 0755 0644
set_perm_recursive "$MODPATH/bin/" 0 0 0755 0755
set_perm_recursive "$MODPATH/bin/" 0 0 0755 0755
set_perm "$MODPATH/opensshd.init" 0 0 0755
set_perm "$MODPATH/post-fs-data.sh" 0 0 0755
set_perm "$MODPATH/service.sh" 0 0 0755
set_perm /data/ssh/sshd_config 0 0 0600
chown shell:shell /data/ssh/shell
chown shell:shell /data/ssh/shell/.ssh
chown root:root /data/ssh/root
chown root:root /data/ssh/root/.ssh
chmod 700 /data/ssh/{shell,root}/.ssh

ui_print "[6/6] Cleaning up"
rm -rf "$TMPDIR"