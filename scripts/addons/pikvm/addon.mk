ifneq ("$(findstring pikvm,$(IMAGE_ADDITIONS))","")
BSPFILTER += "pikvm"
endif

PIKVM_DEPENDS = $(BUILDDIR)/python3-dev-install-stamp

ifneq ("$(findstring libgpiod,$(IMAGE_ADDITIONS))","")
PIKVM_DEPENDS += $(BUILDDIR)/libgpiod-stamp
endif

PIKVM_BUILD_DIR = /rootfs/root/pikvm

$(BUILDDIR)/pikvm-prepare-stamp: $(PIKVM_DEPENDS)
	@echo "$(COLOUR_GREEN)Cloning pikvm for $(BOARD)$(END_COLOUR)"
	@mkdir -p $(PIKVM_BUILD_DIR)/
	@cd $(PIKVM_BUILD_DIR)/ && git clone -b nanokvmpro $(GIT_USER_URL)/pikvm-packages
	@cd $(PIKVM_BUILD_DIR)/ && git clone -b nanokvmpro $(GIT_USER_URL)/janus-gateway
	@cd $(PIKVM_BUILD_DIR)/ && git clone -b nanokvmpro $(GIT_USER_URL)/ustreamer
	@cd $(PIKVM_BUILD_DIR)/ && git clone -b nanokvmpro $(GIT_USER_URL)/kvmd
	@cp -a addons/pikvm/*-build.sh $(PIKVM_BUILD_DIR)/
	@touch $@

$(BUILDDIR)/pikvm-stamp: $(BUILDDIR)/pikvm-prepare-stamp
	@echo "$(COLOUR_GREEN)Building pikvm for $(BOARD)$(END_COLOUR)"
	@#chroot /rootfs apt-get update || true
	@chroot /rootfs mount proc -t proc /proc
	@[ "$(findstring libgpiod,$(IMAGE_ADDITIONS))" = "" ] || chroot /rootfs bash -c 'dpkg -i /tmp/install/libgpiod3_$(LIBGPIOD_VERSION)-$(LIBGPIOD_BUILD)_$(DEB_ARCH).deb'
	@[ "$(findstring libgpiod,$(IMAGE_ADDITIONS))" = "" ] || chroot /rootfs bash -c 'dpkg -i /tmp/install/libgpiod-dev_$(LIBGPIOD_VERSION)-$(LIBGPIOD_BUILD)_$(DEB_ARCH).deb'
	@[ "$(findstring libgpiod,$(IMAGE_ADDITIONS))" = "" ] || chroot /rootfs bash -c 'dpkg -i /tmp/install/gpiod_$(LIBGPIOD_VERSION)-$(LIBGPIOD_BUILD)_$(DEB_ARCH).deb'
	@[ "$(findstring libgpiod,$(IMAGE_ADDITIONS))" = "" -a "$(findstring maixcam2-python3,$(IMAGE_ADDITIONS))" = "" ] || chroot /rootfs pip install gpiod==$(LIBGPIOD_VERSION)
	@chroot /rootfs apt-get install -y libgpiod-dev
	@chroot /rootfs bash -c 'cd /root/pikvm/ && DEB_ARCH=$(DEB_ARCH) bash -e pikvm-build.sh'
	@umount /rootfs/proc || true
	@rm -rf /rootfs/root/pikvm/janus-gateway/
	@rm -rf /rootfs/root/pikvm/ustreamer/
	@rm -rf /rootfs/root/pikvm/kvmd/
	@rm -rf /rootfs/root/pikvm/pikvm-packages/
	@touch $@
