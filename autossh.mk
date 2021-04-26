$(eval $(call start_package))
AUTOSSH?=autossh-1.4g

PACKAGE:=autossh
ARCHIVE_NAME:=$(AUTOSSH).tgz
DOWNLOAD_URL:=https://www.harding.motd.ca/autossh/$(ARCHIVE_NAME)
PACKAGE_INSTALLED_FILES:=$(BUILD_DIR)/system/bin/autossh
SSH_PATH:="/system/xbin/ssh"

CFLAGS+=-I$(BUILD_DIR)/openssl/include -I$(BUILD_DIR)/openssh/include -I$(BUILD_DIR)/autossh
LDFLAGS+=-L$(BUILD_DIR)/openssl/ -L$(BUILD_DIR)/openssh/

define pkg-targets
$(BUILD_DIR)/$(PACKAGE)/stamp.configured: $(SRC_DIR)/$(PACKAGE)/stamp.prepared $(call depend-built,openssl)
	mkdir -p $(BUILD_DIR)/$(PACKAGE)
	cd "$(BUILD_DIR)/$(PACKAGE)";                                  \
	ac_cv_func_malloc_0_nonnull=yes \
	ac_cv_func_realloc_0_nonnull=yes \
	ac_cv_path_ssh=$(SSH_PATH) \
	$(SRC_DIR)/$(PACKAGE)/$(AUTOSSH)/configure                       \
	  --build x86_64-pc-linux-gnu --host $(CROSS)                  \
	  CFLAGS="$(CFLAGS)" CPPFLAGS="$(CFLAGS)" LDFLAGS="$(LDFLAGS)"
	$(make-configured-stamp)

$(BUILD_DIR)/system/bin/autossh: $(BUILD_DIR)/$(PACKAGE)/stamp.built
	mkdir -p $(BUILD_DIR)/system/bin/
	cp -u "$(BUILD_DIR)/$(PACKAGE)/autossh" "$(BUILD_DIR)/system/bin/"
endef

$(eval $(package))