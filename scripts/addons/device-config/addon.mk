$(BUILDDIR)/firmware-vcodec-package-stamp:
	@echo "$(COLOUR_GREEN)Packaging vcodec-firmware for $(BOARD)$(END_COLOUR)"
	@mkdir -p $(BUILDDIR)/package/firmware-vcodec-$(CHIP)-$(MIDDLEWAREVERSION)
	@cp -r /builder/deb/firmware-vcodec-cv181x/* $(BUILDDIR)/package/firmware-vcodec-$(CHIP)-$(MIDDLEWAREVERSION)/
	@mkdir -pv /$(BUILDDIR)/package/firmware-vcodec-$(CHIP)-$(MIDDLEWAREVERSION)/usr/share/fw_vcodec/
	@rsync -avpPxH addons/device-config/overlay/usr/share/fw_vcodec/ /$(BUILDDIR)/package/firmware-vcodec-$(CHIP)-$(MIDDLEWAREVERSION)/usr/share/fw_vcodec/
	@sed -i 's/Version: 1.0.0/Version: $(MIDDLEWAREVERSION)/' $(BUILDDIR)/package/firmware-vcodec-$(CHIP)-$(MIDDLEWAREVERSION)/DEBIAN/control
	@sed -i 's/Package: firmware-vcodec-cv181x/Package: firmware-vcodec-$(CHIP)/' $(BUILDDIR)/package/firmware-vcodec-$(CHIP)-$(MIDDLEWAREVERSION)/DEBIAN/control
	@cd $(BUILDDIR)/package/ && dpkg-deb --build firmware-vcodec-$(CHIP)-$(MIDDLEWAREVERSION) firmware-vcodec-$(CHIP)_$(MIDDLEWAREVERSION)_$(DEB_ARCH).deb
	@cp $(BUILDDIR)/package/firmware-vcodec-$(CHIP)_$(MIDDLEWAREVERSION)_$(DEB_ARCH).deb /output/
	@mkdir -p /rootfs/tmp/install/
	@cp /output/firmware-vcodec-$(CHIP)*.deb /rootfs/tmp/install/
	@touch $@

firmware-vcodec: $(BUILDDIR)/firmware-vcodec-package-stamp

$(BUILDDIR)/sensor-config-install-stamp:
	@mkdir -pv /rootfs/mnt/cfg/param/
	@mkdir -pv /rootfs/mnt/data/
	@if [ "$(BOARD)" = "licheervnano" ]; then \
		cp -p addons/device-config/overlay/mnt/cfg/param/sipeed_gc4653_30fps_202403261356.bin /rootfs/mnt/cfg/param/cvi_sdr_bin ; \
	elif [ "$(BOARD)" = "duo256" ]; then \
		cp -p addons/device-config/overlay/mnt/cfg/param/cvi_sdr_bin_GC2083 /rootfs/mnt/cfg/param/cvi_sdr_bin && \
		cp -p addons/device-config/overlay/mnt/data/sensor_cfg_GC2083.ini /rootfs/mnt/data/sensor_cfg.ini ; \
	fi
	@touch $@

$(BUILDDIR)/sensor-config-package-stamp:
	@echo "$(COLOUR_GREEN)Packaging sensor-config for $(BOARD)$(END_COLOUR)"
	@mkdir -p $(BUILDDIR)/package/sensor-config-$(BOARD)-$(MIDDLEWAREVERSION)
	@cp -r /builder/deb/sensor-config/* $(BUILDDIR)/package/sensor-config-$(BOARD)-$(MIDDLEWAREVERSION)/
	@mkdir -pv /$(BUILDDIR)/package/sensor-config-$(BOARD)-$(MIDDLEWAREVERSION)/mnt/cfg/param/
	@rsync -avpPxH addons/device-config/overlay/mnt/cfg/param/ /$(BUILDDIR)/package/sensor-config-$(BOARD)-$(MIDDLEWAREVERSION)/mnt/cfg/param/
	@rm -f /$(BUILDDIR)/package/sensor-config-$(BOARD)-$(MIDDLEWAREVERSION)/mnt/cfg/param/cvi_sdr_bin
	@mkdir -pv /$(BUILDDIR)/package/sensor-config-$(BOARD)-$(MIDDLEWAREVERSION)/mnt/data/
	@rsync -avpPxH addons/device-config/overlay/mnt/data/ /$(BUILDDIR)/package/sensor-config-$(BOARD)-$(MIDDLEWAREVERSION)/mnt/data/
	@rm -f /$(BUILDDIR)/package/sensor-config-$(BOARD)-$(MIDDLEWAREVERSION)/mnt/data/sensor_cfg.ini
	@sed -i 's/Version: 1.0.0/Version: $(MIDDLEWAREVERSION)/' $(BUILDDIR)/package/sensor-config-$(BOARD)-$(MIDDLEWAREVERSION)/DEBIAN/control
	@sed -i 's/Package: sensor-config/Package: sensor-config-$(BOARD)/' $(BUILDDIR)/package/sensor-config-$(BOARD)-$(MIDDLEWAREVERSION)/DEBIAN/control
	@cd $(BUILDDIR)/package/ && dpkg-deb --build sensor-config-$(BOARD)-$(MIDDLEWAREVERSION) sensor-config-$(BOARD)_$(MIDDLEWAREVERSION)_$(DEB_ARCH).deb
	@cp $(BUILDDIR)/package/sensor-config-$(BOARD)_$(MIDDLEWAREVERSION)_$(DEB_ARCH).deb /output/
	@mkdir -p /rootfs/tmp/install/
	@cp /output/sensor-config-*.deb /rootfs/tmp/install/
	@touch $@

sensor-config: $(BUILDDIR)/sensor-config-install-stamp $(BUILDDIR)/sensor-config-package-stamp

$(BUILDDIR)/device-config-stamp: firmware-vcodec sensor-config
	@echo "$(COLOUR_GREEN)Installing device-config for $(BOARD)$(END_COLOUR)"
	@mkdir -pv /rootfs/etc/init.d/
	@cp -a addons/device-config/S02config /rootfs/etc/init.d/
	@chmod +x /rootfs/etc/init.d/S02config
	@cp -a addons/device-config/device-config*.service /rootfs/etc/systemd/system/
	@mkdir -p /rootfs/tmp/install/
	@echo " device-config" >> /rootfs/tmp/install/systemd-enable
	@touch $@
