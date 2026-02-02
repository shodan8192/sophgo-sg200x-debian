ZRAM_CONFIG_PACKAGE_DIR = $(BUILDDIR)/package/zram-config-$(BOARD)-$(ZRAM_CONFIG_VERSION)

$(BUILDDIR)/zram-config-stamp: $(BUILDDIR)/buildroot-package-stamp
	@echo "$(COLOUR_GREEN)Packaging zram-config for $(BOARD)$(END_COLOUR)"
	@$(eval ZRAMCONFIGVERSION=$(shell echo "1.7.0"))
	@$(eval BV=$(shell cd $(BUILDDIR)/buildroot && git log -1 --format="%at" | xargs -I{} date -d @{} +-%Y%m%d-${KERNELREV}))
	@mkdir -p $(ZRAM_CONFIG_PACKAGE_DIR)
	@cp -r /builder/deb/zram-config/* $(ZRAM_CONFIG_PACKAGE_DIR)/
	@mkdir -pv $(ZRAM_CONFIG_PACKAGE_DIR)/usr/src/zram-config/
	@cd $(ZRAM_CONFIG_PACKAGE_DIR)/usr/src/ && wget -N https://github.com/ecdye/zram-config/releases/download/v$(ZRAMCONFIGVERSION)/zram-config-v$(ZRAMCONFIGVERSION).tar.lz
	@cd $(ZRAM_CONFIG_PACKAGE_DIR)/usr/src/ && tar -xf zram-config-v$(ZRAMCONFIGVERSION).tar.lz --strip-components=1 --directory=zram-config
	@cd $(ZRAM_CONFIG_PACKAGE_DIR)/usr/src/ && rm zram-config-v$(ZRAMCONFIGVERSION).tar.lz
	$(foreach file, $(wildcard /configs/common/patches/zram-config/*.patch), cd $(ZRAM_CONFIG_PACKAGE_DIR)/usr/src/zram-config && git apply --ignore-whitespace $(file);)
	@sed -i s/250M/100M/g $(ZRAM_CONFIG_PACKAGE_DIR)/usr/src/zram-config/ztab
	@sed -i s/750M/300M/g $(ZRAM_CONFIG_PACKAGE_DIR)/usr/src/zram-config/ztab
	@sed -i s/150M/60M/g $(ZRAM_CONFIG_PACKAGE_DIR)/usr/src/zram-config/ztab
	@sed -i s/'\t50M'/'\t20M'/g $(ZRAM_CONFIG_PACKAGE_DIR)/usr/src/zram-config/ztab
	@sed -i 's|/home/pi|/home/debian|g' $(ZRAM_CONFIG_PACKAGE_DIR)/usr/src/zram-config/ztab
	@sed -i 's|/pi.bind|/debian.bind|g' $(ZRAM_CONFIG_PACKAGE_DIR)/usr/src/zram-config/ztab
	@sed -i s/'apt-get install '/'true # no install'/g $(ZRAM_CONFIG_PACKAGE_DIR)/usr/src/zram-config/*.bash
	@sed -i /overlayfs-tools.builddir/d $(ZRAM_CONFIG_PACKAGE_DIR)/usr/src/zram-config/*.bash
	@sed -i s/'systemctl enable --now '/'systemctl enable '/g $(ZRAM_CONFIG_PACKAGE_DIR)/usr/src/zram-config/*.bash
	@sed -i s/'systemctl show -p SubState --value zram-config'/'echo "exited"'/g $(ZRAM_CONFIG_PACKAGE_DIR)/usr/src/zram-config/*.bash
	@sed -i 's/Architecture: riscv64/Architecture: $(DEB_ARCH)/' $(ZRAM_CONFIG_PACKAGE_DIR)/DEBIAN/control
	@sed -i 's/Version: 1.0.0-1/Version: $(ZRAMCONFIGVERSION)$(BV)/' $(ZRAM_CONFIG_PACKAGE_DIR)/DEBIAN/control
	@sed -i 's/Package: zram-config/Package: zram-config-$(BOARD)/' $(ZRAM_CONFIG_PACKAGE_DIR)/DEBIAN/control
	@chmod +x $(ZRAM_CONFIG_PACKAGE_DIR)/DEBIAN/postinst
	@if [ "$(BOARD)" = "duos" ]; then \
		sed -i 's/Duo256/DuoS/' $(ZRAM_CONFIG_PACKAGE_DIR)/DEBIAN/control ; \
	elif [ "$(BOARD)" = "licheervnano" ]; then \
		sed -i s/'MilkV Duo256'/'Sipeed LicheeRV Nano'/ $(ZRAM_CONFIG_PACKAGE_DIR)/DEBIAN/control ; \
	elif [ "$(BOARD)" = "licheea53nano" ]; then \
		sed -i s/'MilkV Duo256'/'Sipeed LicheeA53 Nano'/ $(ZRAM_CONFIG_PACKAGE_DIR)/DEBIAN/control ; \
	fi
	@cd $(BUILDDIR)/package/ && dpkg-deb --build zram-config-$(BOARD)-$(ZRAMCONFIGVERSION) zram-config-$(BOARD)_$(ZRAMCONFIGVERSION)$(BV)_$(DEB_ARCH).deb
	@cp $(BUILDDIR)/package/zram-config-$(BOARD)_$(ZRAMCONFIGVERSION)$(BV)_$(DEB_ARCH).deb /output/
	@mkdir -p /rootfs/tmp/install/
	@cp /output/zram-config-$(BOARD)_$(ZRAMCONFIGVERSION)$(BV)_$(DEB_ARCH).deb /rootfs/tmp/install/
	@touch $@
