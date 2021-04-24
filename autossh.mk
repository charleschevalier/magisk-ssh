$(eval $(call start_package))
AUTOSSH?=autossh-1.4g

PACKAGE:=autossh
ARCHIVE_NAME:=$(AUTOSSH).tgz
DOWNLOAD_URL:=https://www.harding.motd.ca/autossh/$(ARCHIVE_NAME)
PACKAGE_INSTALLED_FILES:=$(BUILD_DIR)/usr/bin/autossh

CFLAGS+=-I$(BUILD_DIR)/openssl/include -I$(BUILD_DIR)/openssh/include -I$(BUILD_DIR)/autossh
LDFLAGS+=-L$(BUILD_DIR)/openssl/ -I$(BUILD_DIR)/openssh/

define pkg-targets
$(BUILD_DIR)/$(PACKAGE)/stamp.configured: $(SRC_DIR)/$(PACKAGE)/stamp.prepared $(call depend-built,openssl)
	mkdir -p $(BUILD_DIR)/$(PACKAGE)
	cd "$(BUILD_DIR)/$(PACKAGE)";                                  \
	$(SRC_DIR)/$(PACKAGE)/$(AUTOSSH)/configure                       \
	  --build x86_64-pc-linux-gnu --host $(CROSS)                  \
	  CFLAGS="$(CFLAGS)" CPPFLAGS="$(CFLAGS)" LDFLAGS="$(LDFLAGS)"
	$(make-configured-stamp)

ifneq ($(IS_SRC_$(PACKAGE)_TARGET_PREPARED),true)
IS_SRC_$(PACKAGE)_TARGET_PREPARED:=true
$(SRC_DIR)/$(PACKAGE)/stamp.prepared: $(SRC_DIR)/$(PACKAGE)/stamp.unpacked
	cd "$(SRC_DIR)/$(PACKAGE)/$(AUTOSSH)"; patch -p1 < "$(ROOT_DIR)/patches/$(AUTOSSH).patch"
	$(make-prepared-stamp)
endif

$(BUILD_DIR)/usr/bin/autossh: $(BUILD_DIR)/$(PACKAGE)/stamp.built
	mkdir -p $(BUILD_DIR)/usr/bin/
	cp -u "$(BUILD_DIR)/$(PACKAGE)/autossh" "$(BUILD_DIR)/usr/bin/"
endef

$(eval $(package))