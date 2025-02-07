$(BUILDDIR)/nanokvm-stamp: $(BUILDDIR)/buildroot-package-stamp
	@echo "$(COLOUR_GREEN)Installing nanokvm for $(BOARD)$(END_COLOUR)"
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
	@echo "$(COLOUR_GREEN)Packaging NanoKVM for $(BOARD)$(END_COLOUR)"
	@$(eval NANOKVMVERSION=$(shell cat $(BR_OUTPUT_DIR)/target/kvmapp/version))
	@$(eval BV=$(shell cd $(BUILDDIR)/buildroot && git log -1 --format="%at" | xargs -I{} date -d @{} +-%Y%m%d-${KERNELREV}))
	@mkdir -p $(BUILDDIR)/package/nanokvm-$(BOARD)-$(NANOKVMVERSION)
	@cp -r /builder/deb/nanokvm-sg200x/* $(BUILDDIR)/package/nanokvm-$(BOARD)-$(NANOKVMVERSION)/
	@mkdir -pv $(BUILDDIR)/package/nanokvm-$(BOARD)-$(NANOKVMVERSION)/kvmapp/
	@rsync -avpPxH $(BR_OUTPUT_DIR)/target/kvmapp/ $(BUILDDIR)/package/nanokvm-$(BOARD)-$(NANOKVMVERSION)/kvmapp/
	@sed -i 's/Version: 1.0.0/Version: $(NANOKVMVERSION)$(BV)/' $(BUILDDIR)/package/nanokvm-$(BOARD)-$(NANOKVMVERSION)/DEBIAN/control
	@sed -i 's/Package: nanokvm-sg200x/Package: nanokvm-$(BOARD)/' $(BUILDDIR)/package/nanokvm-$(BOARD)-$(NANOKVMVERSION)/DEBIAN/control
	@sed -i 's|echo -ne .*x34 > functions/hid.GS1/report_length|echo 52 > functions/hid.GS1/report_length|g' /rootfs/etc/init.d/S03usbdev
	@sed -i s/'i2cdetect -ry'/'i2cdetect -r -y'/g /rootfs/etc/init.d/S15kvmhwd
	@sed -i 's|# cp -r /kvmapp/server|cp -r /kvmapp/server|g' /rootfs/etc/init.d/S95nanokvm
	@sed -i 's|# /tmp/server/NanoKVM-Server|/tmp/server/NanoKVM-Server|g' /rootfs/etc/init.d/S95nanokvm
	@sed -i 's|/tmp/server/NanoKVM-Server &|/tmp/server/NanoKVM-Server|g' /rootfs/etc/init.d/S95nanokvm
	@sed -i /S49ntp/d /rootfs/etc/init.d/S95nanokvm
	@sed -i /'parted -s .dev.mmcblk0 "resizepart 2 -0"'/d $(BUILDDIR)/package/nanokvm-$(BOARD)-$(NANOKVMVERSION)/kvmapp/system/init.d/S01fs
	@sed -i 's|parted ---pretend-input-tty /dev/mmcblk0 "resizepart 2 8192MB"|true|g' $(BUILDDIR)/package/nanokvm-$(BOARD)-$(NANOKVMVERSION)/kvmapp/system/init.d/S01fs
	@sed -i /'resize2fs .dev.mmcblk0p2'/d $(BUILDDIR)/package/nanokvm-$(BOARD)-$(NANOKVMVERSION)/kvmapp/system/init.d/S01fs
	@sed -i /'mkdir -p .boot'/d $(BUILDDIR)/package/nanokvm-$(BOARD)-$(NANOKVMVERSION)/kvmapp/system/init.d/S01fs
	@sed -i /'mount -t vfat .dev.mmcblk0p1'/d $(BUILDDIR)/package/nanokvm-$(BOARD)-$(NANOKVMVERSION)/kvmapp/system/init.d/S01fs
	@sed -i /'mount -t configfs configfs'/d $(BUILDDIR)/package/nanokvm-$(BOARD)-$(NANOKVMVERSION)/kvmapp/system/init.d/S01fs
	@sed -i /'mount -t debugfs debugfs'/d $(BUILDDIR)/package/nanokvm-$(BOARD)-$(NANOKVMVERSION)/kvmapp/system/init.d/S01fs
	@sed -i s/'mkpart primary 8193MB 100%'/'mkpart primary 25% 100%'/g $(BUILDDIR)/package/nanokvm-$(BOARD)-$(NANOKVMVERSION)/kvmapp/system/init.d/S01fs
	@sed -i 's|echo -ne .*x34 > functions/hid.GS1/report_length|echo 52 > functions/hid.GS1/report_length|g' $(BUILDDIR)/package/nanokvm-$(BOARD)-$(NANOKVMVERSION)/kvmapp/system/init.d/S03usbdev
	@sed -i s/'i2cdetect -ry'/'i2cdetect -r -y'/g $(BUILDDIR)/package/nanokvm-$(BOARD)-$(NANOKVMVERSION)/kvmapp/system/init.d/S15kvmhwd
	@sed -i 's|# cp -r /kvmapp/server|cp -r /kvmapp/server|g' $(BUILDDIR)/package/nanokvm-$(BOARD)-$(NANOKVMVERSION)/kvmapp/system/init.d/S95nanokvm
	@sed -i 's|# /tmp/server/NanoKVM-Server|/tmp/server/NanoKVM-Server|g' $(BUILDDIR)/package/nanokvm-$(BOARD)-$(NANOKVMVERSION)/kvmapp/system/init.d/S95nanokvm
	@sed -i 's|/tmp/server/NanoKVM-Server &|/tmp/server/NanoKVM-Server|g' $(BUILDDIR)/package/nanokvm-$(BOARD)-$(NANOKVMVERSION)/kvmapp/system/init.d/S95nanokvm
	@sed -i /S49ntp/d $(BUILDDIR)/package/nanokvm-$(BOARD)-$(NANOKVMVERSION)/kvmapp/system/init.d/S95nanokvm
	@cd $(BUILDDIR)/package/ && dpkg-deb --build nanokvm-$(BOARD)-$(NANOKVMVERSION) nanokvm-$(BOARD)_$(NANOKVMVERSION)$(BV).deb
	@cp $(BUILDDIR)/package/nanokvm-$(BOARD)_$(NANOKVMVERSION)$(BV).deb /output/
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
