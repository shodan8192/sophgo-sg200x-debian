$(BUILDDIR)/nanokvm-stamp: $(BUILDDIR)/buildroot-package-stamp
	@echo "$(COLOUR_GREEN)Installing nanokvm for $(BOARD)$(END_COLOUR)"
	@mkdir -p $(BUILDDIR)
	@mkdir $(BUILDDIR)/nanokvm
	@unzip /output/nanokvm-latest.zip -d $(BUILDDIR)/nanokvm
	@mkdir -p /rootfs/kvmapp/
	@rsync -avpPxH $(BUILDDIR)/nanokvm/latest/ /rootfs/kvmapp/
	@mkdir -pv /rootfs/boot/
	@touch /rootfs/boot/usb.disk0
	@mkdir -pv /rootfs/etc/init.d/
	@cp -a addons/nanokvm/S01fs /rootfs/etc/init.d/
	@chmod +x /rootfs/etc/init.d/S01fs
	@cp -a addons/nanokvm/S03usbdev /rootfs/etc/init.d/
	@chmod +x /rootfs/etc/init.d/S03usbdev
	@cp -a addons/nanokvm/S15kvmhwd /rootfs/etc/init.d/
	@chmod +x /rootfs/etc/init.d/S15kvmhwd
	@cp -a addons/nanokvm/S95nanokvm /rootfs/etc/init.d/
	@chmod +x /rootfs/etc/init.d/S95nanokvm
	@sed -i s/'i2cdetect -ry'/'i2cdetect -r -y'/g /rootfs/etc/init.d/S15kvmhwd
	@sed -i 's|# cp -r /kvmapp/server|cp -r /kvmapp/server|g' /rootfs/etc/init.d/S95nanokvm
	@sed -i 's|# /tmp/server/NanoKVM-Server|/tmp/server/NanoKVM-Server|g' /rootfs/etc/init.d/S95nanokvm
	@sed -i 's|/tmp/server/NanoKVM-Server &|/tmp/server/NanoKVM-Server|g' /rootfs/etc/init.d/S95nanokvm
	@sed -i /S49ntp/d /rootfs/etc/init.d/S95nanokvm
	@sed -i /'parted -s .dev.mmcblk0 "resizepart 2 -0"'/d /rootfs/kvmapp/system/init.d/S01fs
	@sed -i 's|parted ---pretend-input-tty /dev/mmcblk0 "resizepart 2 8192MB"|true|g' /rootfs/kvmapp/system/init.d/S01fs
	@sed -i /'resize2fs .dev.mmcblk0p2'/d /rootfs/kvmapp/system/init.d/S01fs
	@sed -i /'mkdir -p .boot'/d /rootfs/kvmapp/system/init.d/S01fs
	@sed -i /'mount -t vfat .dev.mmcblk0p1'/d /rootfs/kvmapp/system/init.d/S01fs
	@sed -i /'mount -t configfs configfs'/d /rootfs/kvmapp/system/init.d/S01fs
	@sed -i /'mount -t debugfs debugfs'/d /rootfs/kvmapp/system/init.d/S01fs
	@sed -i s/'mkpart primary 8193MB 100%'/'mkpart primary 25% 100%'/g /rootfs/kvmapp/system/init.d/S01fs
	@sed -i s/'i2cdetect -ry'/'i2cdetect -r -y'/g /rootfs/kvmapp/system/init.d/S15kvmhwd
	@sed -i 's|# cp -r /kvmapp/server|cp -r /kvmapp/server|g' /rootfs/kvmapp/system/init.d/S95nanokvm
	@sed -i 's|# /tmp/server/NanoKVM-Server|/tmp/server/NanoKVM-Server|g' /rootfs/kvmapp/system/init.d/S95nanokvm
	@sed -i 's|/tmp/server/NanoKVM-Server &|/tmp/server/NanoKVM-Server|g' /rootfs/kvmapp/system/init.d/S95nanokvm
	@sed -i /S49ntp/d /rootfs/kvmapp/system/init.d/S95nanokvm
	@cp -a addons/nanokvm/kvm-data*.service /rootfs/etc/systemd/system/
	@cp -a addons/nanokvm/kvm-hwd*.service /rootfs/etc/systemd/system/
	@cp -a addons/nanokvm/nanokvm*.service /rootfs/etc/systemd/system/
	@cp -a addons/nanokvm/usb-device*.service /rootfs/etc/systemd/system/
	@mkdir -p /rootfs/tmp/install/
	@echo " usb-device" >> /rootfs/tmp/install/systemd-enable
	@echo " kvm-data" >> /rootfs/tmp/install/systemd-enable
	@echo " kvm-hwd" >> /rootfs/tmp/install/systemd-enable
	@echo " nanokvm" >> /rootfs/tmp/install/systemd-enable
	@touch $@
