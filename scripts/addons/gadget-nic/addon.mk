$(BUILDDIR)/gadget-nic-stamp:
	@echo "$(COLOUR_GREEN)Packaging gadget-nic for $(BOARD)$(END_COLOUR)"
	@$(eval GADGETNICVERSION=$(shell echo "1.0.0"))
	@mkdir -p $(BUILDDIR)/package/gadget-nic-$(BOARD)-$(GADGETNICVERSION)
	@cp -r /builder/deb/gadget-nic/* $(BUILDDIR)/package/gadget-nic-$(BOARD)-$(GADGETNICVERSION)/
	@mkdir -pv $(BUILDDIR)/package/gadget-nic-$(BOARD)-$(GADGETNICVERSION)/etc/init.d/
	@cp -a addons/gadget-nic/S30gadget_nic $(BUILDDIR)/package/gadget-nic-$(BOARD)-$(GADGETNICVERSION)/etc/init.d/
	@chmod +x $(BUILDDIR)/package/gadget-nic-$(BOARD)-$(GADGETNICVERSION)/etc/init.d/S30gadget_nic
	@ln -s S30gadget_nic $(BUILDDIR)/package/gadget-nic-$(BOARD)-$(GADGETNICVERSION)/etc/init.d/S30rndis
	@mkdir -pv $(BUILDDIR)/package/gadget-nic-$(BOARD)-$(GADGETNICVERSION)/etc/systemd/system/
	@cp -a addons/gadget-nic/gadget-nic*.service $(BUILDDIR)/package/gadget-nic-$(BOARD)-$(GADGETNICVERSION)/etc/systemd/system/
	@sed -i 's/Version: 1.0.0/Version: $(GADGETNICVERSION)/' $(BUILDDIR)/package/gadget-nic-$(BOARD)-$(GADGETNICVERSION)/DEBIAN/control
	@sed -i 's/Package: gadget-nic/Package: gadget-nic-$(BOARD)/' $(BUILDDIR)/package/gadget-nic-$(BOARD)-$(GADGETNICVERSION)/DEBIAN/control
	@cd $(BUILDDIR)/package/ && dpkg-deb --build gadget-nic-$(BOARD)-$(GADGETNICVERSION) gadget-nic-$(BOARD)_$(GADGETNICVERSION)_$(DEB_ARCH).deb
	@cp $(BUILDDIR)/package/gadget-nic-$(BOARD)_$(GADGETNICVERSION)_$(DEB_ARCH).deb /output/
	@mkdir -p /rootfs/tmp/install/
	@cp /output/gadget-nic-*.deb /rootfs/tmp/install/
	@echo "$(COLOUR_GREEN)Installing gadget-nic for $(BOARD)$(END_COLOUR)"
	@if [ "X$(findstring kvm,$(VARIANT))" = "X" ]; then \
		mkdir -pv /rootfs/boot/ ; \
		touch /rootfs/boot/usb.rndis ; \
	fi
	@mkdir -p /rootfs/tmp/install/
	@echo " gadget-nic" >> /rootfs/tmp/install/systemd-enable
	@echo " gadget-nic-usb0.service" >> /rootfs/tmp/install/systemd-enable
	@echo " gadget-nic-usb1.service" >> /rootfs/tmp/install/systemd-enable
	@touch $@
