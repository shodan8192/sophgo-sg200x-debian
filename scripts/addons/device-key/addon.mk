$(BUILDDIR)/device-key-stamp:
	@echo "$(COLOUR_GREEN)Packaging device-key for $(BOARD)$(END_COLOUR)"
	@$(eval DEVICEKYVERSION=$(shell echo "1.0.0"))
	@mkdir -p $(BUILDDIR)/package/device-key-$(BOARD)-$(DEVICEKYVERSION)
	@cp -r /builder/deb/device-key/* $(BUILDDIR)/package/device-key-$(BOARD)-$(DEVICEKYVERSION)/
	@mkdir -pv $(BUILDDIR)/package/device-key-$(BOARD)-$(DEVICEKYVERSION)/etc/init.d/
	@cp -a addons/device-key/S02devicekey $(BUILDDIR)/package/device-key-$(BOARD)-$(DEVICEKYVERSION)/etc/init.d/
	@chmod +x $(BUILDDIR)/package/device-key-$(BOARD)-$(DEVICEKYVERSION)/etc/init.d/S02devicekey
	@cp -a addons/device-key/S10uuid $(BUILDDIR)/package/device-key-$(BOARD)-$(DEVICEKYVERSION)/etc/init.d/
	@chmod +x $(BUILDDIR)/package/device-key-$(BOARD)-$(DEVICEKYVERSION)/etc/init.d/S10uuid
	@mkdir -pv $(BUILDDIR)/package/device-key-$(BOARD)-$(DEVICEKYVERSION)/etc/systemd/system/
	@cp -a addons/device-key/device-key*.service $(BUILDDIR)/package/device-key-$(BOARD)-$(DEVICEKYVERSION)/etc/systemd/system/
	@cp -a addons/device-key/device-uuid*.service $(BUILDDIR)/package/device-key-$(BOARD)-$(DEVICEKYVERSION)/etc/systemd/system/
	@sed -i 's/Version: 1.0.0/Version: $(DEVICEKYVERSION)/' $(BUILDDIR)/package/device-key-$(BOARD)-$(DEVICEKYVERSION)/DEBIAN/control
	@sed -i 's/Package: device-key/Package: device-key-$(BOARD)/' $(BUILDDIR)/package/device-key-$(BOARD)-$(DEVICEKYVERSION)/DEBIAN/control
	@cd $(BUILDDIR)/package/ && dpkg-deb --build device-key-$(BOARD)-$(DEVICEKYVERSION) device-key-$(BOARD)_$(DEVICEKYVERSION)_$(DEB_ARCH).deb
	@cp $(BUILDDIR)/package/device-key-$(BOARD)_$(DEVICEKYVERSION)_$(DEB_ARCH).deb /output/
	@mkdir -p /rootfs/tmp/install/
	@cp /output/device-key-*.deb /rootfs/tmp/install/
	@echo "$(COLOUR_GREEN)Installing device-key for $(BOARD)$(END_COLOUR)"
	@mkdir -pv /rootfs/boot/
	@[ "$(BOARD)" = "licheervnano" ] || echo $(BOARD) > /rootfs/boot/hostname.prefix
	@mkdir -p /rootfs/tmp/install/
	@echo " device-key" >> /rootfs/tmp/install/systemd-enable
	@echo " device-uuid" >> /rootfs/tmp/install/systemd-enable
	@touch $@
