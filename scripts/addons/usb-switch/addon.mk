$(BUILDDIR)/usb-switch-stamp:
	@echo "$(COLOUR_GREEN)Packaging USB Switch for $(BOARD)$(END_COLOUR)"
	@$(eval USBSWITCHVERSION=$(shell echo "1.0.0"))
	@mkdir -p $(BUILDDIR)/package/usb-switch-$(BOARD)-$(USBSWITCHVERSION)
	@cp -r /builder/deb/usb-switch/* $(BUILDDIR)/package/usb-switch-$(BOARD)-$(USBSWITCHVERSION)/
	@mkdir -p $(BUILDDIR)/package/usb-switch-$(BOARD)-$(USBSWITCHVERSION)/etc/systemd/system/
	@cp -a addons/usb-switch/usb-switch.service $(BUILDDIR)/package/usb-switch-$(BOARD)-$(USBSWITCHVERSION)/etc/systemd/system/
	@sed -i 's/Version: 1.0.0/Version: $(USBSWITCHVERSION)/' $(BUILDDIR)/package/usb-switch-$(BOARD)-$(USBSWITCHVERSION)/DEBIAN/control
	@sed -i 's/Package: usb-switch/Package: usb-switch-$(BOARD)/' $(BUILDDIR)/package/usb-switch-$(BOARD)-$(USBSWITCHVERSION)/DEBIAN/control
	@cd $(BUILDDIR)/package/ && dpkg-deb --build usb-switch-$(BOARD)-$(USBSWITCHVERSION) usb-switch-$(BOARD)_$(USBSWITCHVERSION)_$(DEB_ARCH).deb
	@cp $(BUILDDIR)/package/usb-switch-$(BOARD)_$(USBSWITCHVERSION)_$(DEB_ARCH).deb /output/
	@mkdir -p /rootfs/tmp/install/
	@cp /output/usb-switch-*.deb /rootfs/tmp/install/
	@echo "$(COLOUR_GREEN)Installing USB Switch for $(BOARD)$(END_COLOUR)"
	@mkdir -p /rootfs/tmp/install/
	@touch $@
