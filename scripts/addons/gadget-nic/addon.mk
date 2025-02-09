$(BUILDDIR)/gadget-nic-stamp:
	@echo "$(COLOUR_GREEN)Installing gadget-nic for $(BOARD)$(END_COLOUR)"
	@mkdir -pv /rootfs/boot/
	@touch /rootfs/boot/usb.rndis
	@mkdir -pv /rootfs/etc/init.d/
	@cp -a addons/gadget-nic/S30gadget_nic /rootfs/etc/init.d/
	@chmod +x /rootfs/etc/init.d/S30gadget_nic
	@cp -a addons/gadget-nic/gadget-nic*.service /rootfs/etc/systemd/system/
	@mkdir -p /rootfs/tmp/install/
	@echo " gadget-nic" >> /rootfs/tmp/install/systemd-enable
	@echo " gadget-nic-usb0.service" >> /rootfs/tmp/install/systemd-enable
	@echo " gadget-nic-usb1.service" >> /rootfs/tmp/install/systemd-enable
	@touch $@
