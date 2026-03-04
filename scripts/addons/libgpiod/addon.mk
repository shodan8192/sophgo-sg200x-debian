ifneq ("$(findstring libgpiod,$(IMAGE_ADDITIONS))","")
BSPFILTER += "libgpiod"
endif

LIBGPIOD_VERSION = 2.2.1
LIBGPIOD_BUILD = 2

LIBGPIOD_BASE_URL = https://ports.ubuntu.com/ubuntu-ports/pool/universe/libg/libgpiod

LIBGPIOD_DL_DIR = $(BUILDDIR)/libgpiod

$(BUILDDIR)/libgpiod-prepare-stamp:
	@echo "$(COLOUR_GREEN)Building libgpiod for $(BOARD)$(END_COLOUR)"
	@mkdir -p $(LIBGPIOD_DL_DIR)
	@cd $(LIBGPIOD_DL_DIR) && wget -N $(LIBGPIOD_BASE_URL)/libgpiod_$(LIBGPIOD_VERSION)-$(LIBGPIOD_BUILD).debian.tar.xz || wget -N $(USER_SITE_URL)/deb/pool/$(CHIP_FAMILY)/libgpiod_$(LIBGPIOD_VERSION)-$(LIBGPIOD_BUILD).debian.tar.xz
	@cd $(LIBGPIOD_DL_DIR) && wget -N $(LIBGPIOD_BASE_URL)/libgpiod_$(LIBGPIOD_VERSION)-$(LIBGPIOD_BUILD).dsc || wget -N $(USER_SITE_URL)/deb/pool/$(CHIP_FAMILY)/libgpiod_$(LIBGPIOD_VERSION)-$(LIBGPIOD_BUILD).dsc
	@cd $(LIBGPIOD_DL_DIR) && wget -N $(LIBGPIOD_BASE_URL)/libgpiod_$(LIBGPIOD_VERSION).orig.tar.xz || wget -N $(USER_SITE_URL)/deb/pool/$(CHIP_FAMILY)/libgpiod_$(LIBGPIOD_VERSION).orig.tar.xz
	@mkdir /rootfs/root/source-libgpiod && \
		cp -p $(LIBGPIOD_DL_DIR)/libgpiod_* /rootfs/root/source-libgpiod/ && \
		echo OK
	@cd /rootfs/root/source-libgpiod/ && \
		tar xJf libgpiod_$(LIBGPIOD_VERSION).orig.tar.xz && \
		cd libgpiod-$(LIBGPIOD_VERSION)/ && \
		tar xJf ../libgpiod_$(LIBGPIOD_VERSION)-$(LIBGPIOD_BUILD).debian.tar.xz && \
		echo OK
	@touch $@

$(BUILDDIR)/libgpiod-stamp: $(BUILDDIR)/libgpiod-prepare-stamp
	@echo "$(COLOUR_GREEN)Packaging libgpiod for $(BOARD)$(END_COLOUR)"
	@chroot /rootfs apt-get update || true
	@chroot /rootfs apt-get install -y debhelper autoconf-archive automake dh-python help2man pkgconf doxygen
	@chroot /rootfs apt-get install -y graphviz python3-all-dev libpython3-all-dev python3-pip python3-setuptools python3-venv pybuild-plugin-pyproject
	@chroot /rootfs bash -c 'cd /root/source-libgpiod/libgpiod-$(LIBGPIOD_VERSION)/ && dpkg-buildpackage'
	@[ "$(findstring maixcam2-python3,$(IMAGE_ADDITIONS))" = "" ] || chroot /rootfs apt-get remove --purge -y python3-pip
	@rm -rf /rootfs/root/source-libgpiod/libgpiod-$(LIBGPIOD_VERSION)/
	@cp -p /rootfs/root/source-libgpiod/gpiod_$(LIBGPIOD_VERSION)-$(LIBGPIOD_BUILD)_$(DEB_ARCH).deb /output/
	@cp -p /rootfs/root/source-libgpiod/libgpiod3_$(LIBGPIOD_VERSION)-$(LIBGPIOD_BUILD)_$(DEB_ARCH).deb /output/
	@cp -p /rootfs/root/source-libgpiod/libgpiod-dev_$(LIBGPIOD_VERSION)-$(LIBGPIOD_BUILD)_$(DEB_ARCH).deb /output/
	@cp -p /rootfs/root/source-libgpiod/python3-libgpiod_$(LIBGPIOD_VERSION)-$(LIBGPIOD_BUILD)_$(DEB_ARCH).deb /output/
	@mkdir -p /rootfs/tmp/install/
	@cp -p /rootfs/root/source-libgpiod/gpiod_$(LIBGPIOD_VERSION)-$(LIBGPIOD_BUILD)_$(DEB_ARCH).deb /rootfs/tmp/install/
	@cp -p /rootfs/root/source-libgpiod/libgpiod3_$(LIBGPIOD_VERSION)-$(LIBGPIOD_BUILD)_$(DEB_ARCH).deb /rootfs/tmp/install/
	@cp -p /rootfs/root/source-libgpiod/libgpiod-dev_$(LIBGPIOD_VERSION)-$(LIBGPIOD_BUILD)_$(DEB_ARCH).deb /rootfs/tmp/install/
	@cp -p /rootfs/root/source-libgpiod/python3-libgpiod_$(LIBGPIOD_VERSION)-$(LIBGPIOD_BUILD)_$(DEB_ARCH).deb /rootfs/tmp/install/
	@[ "$(GIT_REF)" = "develop" ] || rm -rf /rootfs/root/source-libgpiod/
	@touch $@
