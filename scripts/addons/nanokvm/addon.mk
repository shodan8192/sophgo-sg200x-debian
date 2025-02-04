$(BUILDDIR)/nanokvm-stamp: $(BUILDDIR)/buildroot-package-stamp
	@echo "$(COLOUR_GREEN)Installing nanokvm for $(BOARD)$(END_COLOUR)"
	@mkdir -p $(BUILDDIR)
	@mkdir $(BUILDDIR)/nanokvm
	@unzip /output/nanokvm-latest.zip -d $(BUILDDIR)/nanokvm
	@mkdir -p /rootfs/kvmapp/
	@rsync -avpPxH $(BUILDDIR)/nanokvm/latest/ /rootfs/kvmapp/
	@mkdir -pv /rootfs/etc/init.d/
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
	@sed -i s/'i2cdetect -ry'/'i2cdetect -r -y'/g /rootfs/kvmapp/system/init.d/S15kvmhwd
	@sed -i 's|# cp -r /kvmapp/server|cp -r /kvmapp/server|g' /rootfs/kvmapp/system/init.d/S95nanokvm
	@sed -i 's|# /tmp/server/NanoKVM-Server|/tmp/server/NanoKVM-Server|g' /rootfs/kvmapp/system/init.d/S95nanokvm
	@sed -i 's|/tmp/server/NanoKVM-Server &|/tmp/server/NanoKVM-Server|g' /rootfs/kvmapp/system/init.d/S95nanokvm
	@sed -i /S49ntp/d /rootfs/kvmapp/system/init.d/S95nanokvm
	@cp -a addons/nanokvm/kvm-hwd*.service /rootfs/etc/systemd/system/
	@cp -a addons/nanokvm/nanokvm*.service /rootfs/etc/systemd/system/
	@cp -a addons/nanokvm/usb-device*.service /rootfs/etc/systemd/system/
	@mkdir -p /rootfs/tmp/install/
	@echo " usb-device" >> /rootfs/tmp/install/systemd-enable
	@echo " kvm-hwd" >> /rootfs/tmp/install/systemd-enable
	@echo " nanokvm" >> /rootfs/tmp/install/systemd-enable
	@touch $@
