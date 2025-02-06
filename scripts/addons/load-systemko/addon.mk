$(BUILDDIR)/load-systemko-stamp:
	@echo "$(COLOUR_GREEN)Installing load-systemko for $(BOARD)$(END_COLOUR)"
	@mkdir -pv /rootfs/etc/init.d/
	@cp -a addons/load-systemko/S00kmod /rootfs/etc/init.d/
	@chmod +x /rootfs/etc/init.d/S00kmod
	@cp -a addons/load-systemko/S04backlight /rootfs/etc/init.d/
	@chmod +x /rootfs/etc/init.d/S04backlight
	@cp -a addons/load-systemko/S04fb /rootfs/etc/init.d/
	@chmod +x /rootfs/etc/init.d/S04fb
	@cp -a addons/load-systemko/S05tp /rootfs/etc/init.d/
	@chmod +x /rootfs/etc/init.d/S05tp
	@cp -a addons/load-systemko/S25wifimod /rootfs/etc/init.d/
	@chmod +x /rootfs/etc/init.d/S25wifimod
	@cp -a addons/load-systemko/load-systemko*.service /rootfs/etc/systemd/system/
	@cp -a addons/load-systemko/enable-backlight*.service /rootfs/etc/systemd/system/
	@cp -a addons/load-systemko/load-fb*.service /rootfs/etc/systemd/system/
	@cp -a addons/load-systemko/load-tp*.service /rootfs/etc/systemd/system/
	@cp -a addons/load-systemko/load-wifimod*.service /rootfs/etc/systemd/system/
	@mkdir -p /rootfs/tmp/install/
	@echo " load-systemko" >> /rootfs/tmp/install/systemd-enable
	@echo " enable-backlight" >> /rootfs/tmp/install/systemd-enable
	@echo " load-fb" >> /rootfs/tmp/install/systemd-enable
	@echo " load-tp" >> /rootfs/tmp/install/systemd-enable
	@echo " load-wifimod" >> /rootfs/tmp/install/systemd-enable
	@touch $@
