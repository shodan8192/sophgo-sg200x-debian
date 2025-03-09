$(BUILDDIR)/load-systemko-stamp:
	@echo "$(COLOUR_GREEN)Packaging load-systemko for $(BOARD)$(END_COLOUR)"
	@mkdir -p $(BUILDDIR)/package/load-systemko-$(BOARD)-$(OSDRVVERSION)
	@cp -r /builder/deb/load-systemko/* $(BUILDDIR)/package/load-systemko-$(BOARD)-$(OSDRVVERSION)/
	@mkdir -pv $(BUILDDIR)/package/load-systemko-$(BOARD)-$(OSDRVVERSION)/etc/init.d/
	@cp -a addons/load-systemko/S00kmod $(BUILDDIR)/package/load-systemko-$(BOARD)-$(OSDRVVERSION)/etc/init.d/
	@chmod +x $(BUILDDIR)/package/load-systemko-$(BOARD)-$(OSDRVVERSION)/etc/init.d/S00kmod
	@cp -a addons/load-systemko/S04backlight $(BUILDDIR)/package/load-systemko-$(BOARD)-$(OSDRVVERSION)/etc/init.d/
	@chmod +x $(BUILDDIR)/package/load-systemko-$(BOARD)-$(OSDRVVERSION)/etc/init.d/S04backlight
	@cp -a addons/load-systemko/S04fb $(BUILDDIR)/package/load-systemko-$(BOARD)-$(OSDRVVERSION)/etc/init.d/
	@chmod +x $(BUILDDIR)/package/load-systemko-$(BOARD)-$(OSDRVVERSION)/etc/init.d/S04fb
	@cp -a addons/load-systemko/S05tp $(BUILDDIR)/package/load-systemko-$(BOARD)-$(OSDRVVERSION)/etc/init.d/
	@chmod +x $(BUILDDIR)/package/load-systemko-$(BOARD)-$(OSDRVVERSION)/etc/init.d/S05tp
	@cp -a addons/load-systemko/S25wifimod $(BUILDDIR)/package/load-systemko-$(BOARD)-$(OSDRVVERSION)/etc/init.d/
	@chmod +x $(BUILDDIR)/package/load-systemko-$(BOARD)-$(OSDRVVERSION)/etc/init.d/S25wifimod
	@mkdir -pv $(BUILDDIR)/package/load-systemko-$(BOARD)-$(OSDRVVERSION)/etc/systemd/system/
	@cp -a addons/load-systemko/load-systemko*.service $(BUILDDIR)/package/load-systemko-$(BOARD)-$(OSDRVVERSION)/etc/systemd/system/
	@cp -a addons/load-systemko/enable-backlight*.service $(BUILDDIR)/package/load-systemko-$(BOARD)-$(OSDRVVERSION)/etc/systemd/system/
	@cp -a addons/load-systemko/load-fb*.service $(BUILDDIR)/package/load-systemko-$(BOARD)-$(OSDRVVERSION)/etc/systemd/system/
	@cp -a addons/load-systemko/load-tp*.service $(BUILDDIR)/package/load-systemko-$(BOARD)-$(OSDRVVERSION)/etc/systemd/system/
	@cp -a addons/load-systemko/load-wifimod*.service $(BUILDDIR)/package/load-systemko-$(BOARD)-$(OSDRVVERSION)/etc/systemd/system/
	@sed -i 's/Version: 1.0.0/Version: $(OSDRVVERSION)/' $(BUILDDIR)/package/load-systemko-$(BOARD)-$(OSDRVVERSION)/DEBIAN/control
	@sed -i 's/Package: load-systemko/Package: load-systemko-$(BOARD)/' $(BUILDDIR)/package/load-systemko-$(BOARD)-$(OSDRVVERSION)/DEBIAN/control
	@cd $(BUILDDIR)/package/ && dpkg-deb --build load-systemko-$(BOARD)-$(OSDRVVERSION) load-systemko-$(BOARD)_$(OSDRVVERSION)_$(DEB_ARCH).deb
	@cp $(BUILDDIR)/package/load-systemko-$(BOARD)_$(OSDRVVERSION)_$(DEB_ARCH).deb /output/
	@mkdir -p /rootfs/tmp/install/
	@cp /output/load-systemko-*.deb /rootfs/tmp/install/
	@echo "$(COLOUR_GREEN)Installing load-systemko for $(BOARD)$(END_COLOUR)"
	@mkdir -p /rootfs/tmp/install/
	@echo " load-systemko" >> /rootfs/tmp/install/systemd-enable
	@echo " enable-backlight" >> /rootfs/tmp/install/systemd-enable
	@echo " load-fb" >> /rootfs/tmp/install/systemd-enable
	@echo " load-tp" >> /rootfs/tmp/install/systemd-enable
	@echo " load-wifimod" >> /rootfs/tmp/install/systemd-enable
	@touch $@
