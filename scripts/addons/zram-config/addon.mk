$(BUILDDIR)/zram-config-stamp: $(BUILDDIR)/buildroot-package-stamp
	@echo "$(COLOUR_GREEN)Packaging zram-config for $(BOARD)$(END_COLOUR)"
	@$(eval ZRAMCONFIGVERSION=$(shell echo "1.7.0"))
	@$(eval BV=$(shell cd $(BUILDDIR)/buildroot && git log -1 --format="%at" | xargs -I{} date -d @{} +-%Y%m%d-${KERNELREV}))
	@mkdir -p $(BUILDDIR)/package/zram-config-$(BOARD)-$(ZRAMCONFIGVERSION)
	@cp -r /builder/deb/zram-config/* $(BUILDDIR)/package/zram-config-$(BOARD)-$(ZRAMCONFIGVERSION)/
	@mkdir -pv $(BUILDDIR)/package/zram-config-$(BOARD)-$(ZRAMCONFIGVERSION)/usr/src/zram-config/
	@cd $(BUILDDIR)/package/zram-config-$(BOARD)-$(ZRAMCONFIGVERSION)/usr/src/ && wget -N https://github.com/ecdye/zram-config/releases/download/v$(ZRAMCONFIGVERSION)/zram-config-v$(ZRAMCONFIGVERSION).tar.lz
	@cd $(BUILDDIR)/package/zram-config-$(BOARD)-$(ZRAMCONFIGVERSION)/usr/src/ && tar -xf zram-config-v$(ZRAMCONFIGVERSION).tar.lz --strip-components=1 --directory=zram-config
	@cd $(BUILDDIR)/package/zram-config-$(BOARD)-$(ZRAMCONFIGVERSION)/usr/src/ && rm zram-config-v$(ZRAMCONFIGVERSION).tar.lz
	@sed -i s/250M/100M/g $(BUILDDIR)/package/zram-config-$(BOARD)-$(ZRAMCONFIGVERSION)/usr/src/zram-config/ztab
	@sed -i s/750M/300M/g $(BUILDDIR)/package/zram-config-$(BOARD)-$(ZRAMCONFIGVERSION)/usr/src/zram-config/ztab
	@sed -i s/150M/60M/g $(BUILDDIR)/package/zram-config-$(BOARD)-$(ZRAMCONFIGVERSION)/usr/src/zram-config/ztab
	@sed -i s/'\t50M'/'\t20M'/g $(BUILDDIR)/package/zram-config-$(BOARD)-$(ZRAMCONFIGVERSION)/usr/src/zram-config/ztab
	@sed -i 's|/home/pi|/home/debian|g' $(BUILDDIR)/package/zram-config-$(BOARD)-$(ZRAMCONFIGVERSION)/usr/src/zram-config/ztab
	@sed -i 's|/pi.bind|/debian.bind|g' $(BUILDDIR)/package/zram-config-$(BOARD)-$(ZRAMCONFIGVERSION)/usr/src/zram-config/ztab
	@sed -i s/'apt-get install '/'true # no install'/g $(BUILDDIR)/package/zram-config-$(BOARD)-$(ZRAMCONFIGVERSION)/usr/src/zram-config/*.bash
	@sed -i /overlayfs-tools.builddir/d $(BUILDDIR)/package/zram-config-$(BOARD)-$(ZRAMCONFIGVERSION)/usr/src/zram-config/*.bash
	@sed -i s/'systemctl enable --now '/'systemctl enable '/g $(BUILDDIR)/package/zram-config-$(BOARD)-$(ZRAMCONFIGVERSION)/usr/src/zram-config/*.bash
	@sed -i s/'systemctl show -p SubState --value zram-config'/'echo "exited"'/g $(BUILDDIR)/package/zram-config-$(BOARD)-$(ZRAMCONFIGVERSION)/usr/src/zram-config/*.bash
	@sed -i 's/Architecture: riscv64/Architecture: $(DEB_ARCH)/' $(BUILDDIR)/package/zram-config-$(BOARD)-$(ZRAMCONFIGVERSION)/DEBIAN/control
	@sed -i 's/Version: 1.0.0-1/Version: $(ZRAMCONFIGVERSION)$(BV)/' $(BUILDDIR)/package/zram-config-$(BOARD)-$(ZRAMCONFIGVERSION)/DEBIAN/control
	@sed -i 's/Package: zram-config/Package: zram-config-$(BOARD)/' $(BUILDDIR)/package/zram-config-$(BOARD)-$(ZRAMCONFIGVERSION)/DEBIAN/control
	@echo '#!/bin/sh' > $(BUILDDIR)/package/zram-config-$(BOARD)-$(ZRAMCONFIGVERSION)/DEBIAN/postinst
	@echo '[ -e /usr/local/sbin/zram-config -o -e /usr/sbin/zram-config ] || /usr/src/zram-config/install.bash' >> $(BUILDDIR)/package/zram-config-$(BOARD)-$(ZRAMCONFIGVERSION)/DEBIAN/postinst
	@chmod +x $(BUILDDIR)/package/zram-config-$(BOARD)-$(ZRAMCONFIGVERSION)/DEBIAN/postinst
	@if [ "$(BOARD)" = "duos" ]; then \
		sed -i 's/Duo256/DuoS/' $(BUILDDIR)/package/zram-config-$(BOARD)-$(ZRAMCONFIGVERSION)/DEBIAN/control ; \
	elif [ "$(BOARD)" = "licheervnano" ]; then \
		sed -i s/'MilkV Duo256'/'Sipeed LicheeRV Nano'/ $(BUILDDIR)/package/zram-config-$(BOARD)-$(ZRAMCONFIGVERSION)/DEBIAN/control ; \
	elif [ "$(BOARD)" = "licheea53nano" ]; then \
		sed -i s/'MilkV Duo256'/'Sipeed LicheeA53 Nano'/ $(BUILDDIR)/package/zram-config-$(BOARD)-$(ZRAMCONFIGVERSION)/DEBIAN/control ; \
	fi
	@cd $(BUILDDIR)/package/ && dpkg-deb --build zram-config-$(BOARD)-$(ZRAMCONFIGVERSION) zram-config-$(BOARD)_$(ZRAMCONFIGVERSION)$(BV)_$(DEB_ARCH).deb
	@cp $(BUILDDIR)/package/zram-config-$(BOARD)_$(ZRAMCONFIGVERSION)$(BV)_$(DEB_ARCH).deb /output/
	@cp /output/zram-config-$(BOARD)_$(ZRAMCONFIGVERSION)$(BV)_$(DEB_ARCH).deb /rootfs/tmp/install/
	@touch $@
