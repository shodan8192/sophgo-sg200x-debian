$(BUILDDIR)/wifi-builtin-stamp:
	@echo "$(COLOUR_GREEN)Installing wifi-builtin for $(BOARD)$(END_COLOUR)"
	@if [ "X$(findstring kvm,$(VARIANT))" = "X" ]; then \
		mkdir -pv /rootfs/etc/init.d/ ; \
		cp -a addons/wifi-builtin/S30wifi /rootfs/etc/init.d/ ; \
		chmod +x /rootfs/etc/init.d/S30wifi ; \
	fi
	@mkdir -pv /rootfs/etc/network/interfaces.d/
	@cp -a addons/wifi-builtin/wlan0 /rootfs/etc/network/interfaces.d/
	@cp -a addons/wifi-builtin/wifi-builtin*.service /rootfs/etc/systemd/system/
	@cp -a addons/wifi-builtin/wifi-hostapd*.service /rootfs/etc/systemd/system/
	@mkdir -p /rootfs/tmp/install/
	@echo " wifi-builtin" >> /rootfs/tmp/install/systemd-enable
	@echo " wifi-builtin-wlan0.service" >> /rootfs/tmp/install/systemd-enable
	@echo " wifi-hostapd-wlan0.service" >> /rootfs/tmp/install/systemd-enable
	@touch $@
