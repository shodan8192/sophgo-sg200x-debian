$(BUILDDIR)/device-key-stamp:
	@echo "$(COLOUR_GREEN)Installing device-key for $(BOARD)$(END_COLOUR)"
	@mkdir -pv /rootfs/etc/init.d/
	@cp -a addons/device-key/S02devicekey /rootfs/etc/init.d/
	@chmod +x /rootfs/etc/init.d/S02devicekey
	@cp -a addons/device-key/S10uuid /rootfs/etc/init.d/
	@chmod +x /rootfs/etc/init.d/S10uuid
	@cp -a addons/device-key/device-key*.service /rootfs/etc/systemd/system/
	@mkdir -p /rootfs/tmp/install/
	@echo " device-key" >> /rootfs/tmp/install/systemd-enable
	@touch $@
