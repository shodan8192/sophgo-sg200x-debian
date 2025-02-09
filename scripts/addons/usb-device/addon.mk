$(BUILDDIR)/usb-device-stamp:
	@echo "$(COLOUR_GREEN)Installing usb-device for $(BOARD)$(END_COLOUR)"
	@mkdir -pv /rootfs/boot/
	@touch /rootfs/boot/usb.dev
	@mkdir -pv /rootfs/etc/init.d/
	@cp -a addons/usb-device/S03usbdev /rootfs/etc/init.d/
	@chmod +x /rootfs/etc/init.d/S03usbdev
	@cp -a addons/usb-device/usb-device*.service /rootfs/etc/systemd/system/
	@mkdir -p /rootfs/tmp/install/
	@echo " usb-device" >> /rootfs/tmp/install/systemd-enable
	@touch $@
