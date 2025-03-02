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

$(BUILDDIR)/device-config-stamp: firmware-vcodec
	@echo "$(COLOUR_GREEN)Installing device-config for $(BOARD)$(END_COLOUR)"
	@mkdir -pv /rootfs/etc/init.d/
	@cp -a addons/device-config/S02config /rootfs/etc/init.d/
	@chmod +x /rootfs/etc/init.d/S02config
	@cp -a addons/device-config/device-config*.service /rootfs/etc/systemd/system/
	@mkdir -pv /rootfs/mnt/
	@rsync -avpPxH addons/device-config/overlay/mnt/ /rootfs/mnt/
	@mkdir -p /rootfs/tmp/install/
	@echo " device-config" >> /rootfs/tmp/install/systemd-enable
	@touch $@
