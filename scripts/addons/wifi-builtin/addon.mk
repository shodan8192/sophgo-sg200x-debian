$(BUILDDIR)/wifi-builtin-stamp: $(BUILDDIR)/buildroot-prepare-checkout-stamp
	@echo "$(COLOUR_GREEN)Packaging wifi-builtin for $(BOARD)$(END_COLOUR)"
	@$(eval WIFIBIVERSION=$(shell echo "1.0.0"))
	@$(eval BV=$(shell cd $(BUILDDIR)/buildroot && git log -1 --format="%at" | xargs -I{} date -d @{} +-%Y%m%d-${KERNELREV}))
	@mkdir -p $(BUILDDIR)/package/wifi-builtin-$(BOARD)-$(WIFIBIVERSION)
	@cp -r /builder/deb/wifi-builtin/* $(BUILDDIR)/package/wifi-builtin-$(BOARD)-$(WIFIBIVERSION)/
	@mkdir -pv $(BUILDDIR)/package/wifi-builtin-$(BOARD)-$(WIFIBIVERSION)/etc/init.d/
	@if [ "X$(findstring kvm,$(VARIANT))" = "X" ]; then \
		cp -a addons/wifi-builtin/S30wifi $(BUILDDIR)/package/wifi-builtin-$(BOARD)-$(WIFIBIVERSION)/etc/init.d/ ; \
	else \
		cp -a addons/nanokvm/S30wifi $(BUILDDIR)/package/wifi-builtin-$(BOARD)-$(WIFIBIVERSION)/etc/init.d/ ; \
	fi
	@chmod +x $(BUILDDIR)/package/wifi-builtin-$(BOARD)-$(WIFIBIVERSION)/etc/init.d/S30wifi
	@mkdir -pv $(BUILDDIR)/package/wifi-builtin-$(BOARD)-$(WIFIBIVERSION)/etc/systemd/system/
	@cp -a addons/wifi-builtin/wifi-builtin*.service $(BUILDDIR)/package/wifi-builtin-$(BOARD)-$(WIFIBIVERSION)/etc/systemd/system/
	@cp -a addons/wifi-builtin/wifi-hostapd*.service $(BUILDDIR)/package/wifi-builtin-$(BOARD)-$(WIFIBIVERSION)/etc/systemd/system/
	@sed -i 's/Version: 1.0.0/Version: $(WIFIBIVERSION)$(BV)/' $(BUILDDIR)/package/wifi-builtin-$(BOARD)-$(WIFIBIVERSION)/DEBIAN/control
	@sed -i 's/Package: wifi-builtin/Package: wifi-builtin-$(BOARD)/' $(BUILDDIR)/package/wifi-builtin-$(BOARD)-$(WIFIBIVERSION)/DEBIAN/control
	@cd $(BUILDDIR)/package/ && dpkg-deb --build wifi-builtin-$(BOARD)-$(WIFIBIVERSION) wifi-builtin-$(BOARD)_$(WIFIBIVERSION)$(BV)_$(DEB_ARCH).deb
	@cp $(BUILDDIR)/package/wifi-builtin-$(BOARD)_$(WIFIBIVERSION)$(BV)_$(DEB_ARCH).deb /output/
	@mkdir -p /rootfs/tmp/install/
	@cp /output/wifi-builtin-*.deb /rootfs/tmp/install/
	@echo "$(COLOUR_GREEN)Installing wifi-builtin for $(BOARD)$(END_COLOUR)"
	@mkdir -pv /rootfs/etc/network/interfaces.d/
	@cp -a addons/wifi-builtin/wlan0 /rootfs/etc/network/interfaces.d/
	@mkdir -p /rootfs/tmp/install/
	@echo " wifi-builtin" >> /rootfs/tmp/install/systemd-enable
	@echo " wifi-builtin-wlan0.service" >> /rootfs/tmp/install/systemd-enable
	@echo " wifi-hostapd-wlan0.service" >> /rootfs/tmp/install/systemd-enable
	@touch $@
