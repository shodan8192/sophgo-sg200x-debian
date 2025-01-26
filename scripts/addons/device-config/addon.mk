$(BUILDDIR)/device-config-stamp:
	@echo "$(COLOUR_GREEN)Installing device-config for $(BOARD)$(END_COLOUR)"
	@mkdir -pv /rootfs/etc/init.d/
	@cp -a addons/device-config/S02config /rootfs/etc/init.d/
	@chmod +x /rootfs/etc/init.d/S02config
	@cp -a addons/device-config/device-config*.service /rootfs/etc/systemd/system/
	@mkdir -pv /rootfs/mnt/
	@rsync -avpPxH addons/device-config/overlay/mnt/ /rootfs/mnt/
	@mkdir -pv /rootfs/usr/share/fw_vcodec/
	@rsync -avpPxH addons/device-config/overlay/usr/share/fw_vcodec/ /rootfs/usr/share/fw_vcodec/
	@mkdir -p /rootfs/tmp/install/
	@echo " device-config" >> /rootfs/tmp/install/systemd-enable
	@touch $@
