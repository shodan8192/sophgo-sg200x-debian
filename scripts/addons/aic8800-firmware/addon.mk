ifneq ("$(findstring aic8800-firmware,$(IMAGE_ADDITIONS))","")
BSPDEPENDS += firmware-aic8800-$(CHIP)
BSPFILTER += "aic8800-firmware"
endif

$(BUILDDIR)/aic8800-firmware-stamp:
	@echo "$(COLOUR_GREEN)Installing aic8800-firmware for $(BOARD)$(END_COLOUR)"
	@rm -rf $(BUILDDIR)/aic8800-firmware
	@git clone --depth 1 https://github.com/armbian/firmware.git $(BUILDDIR)/aic8800-firmware
	@echo "$(COLOUR_GREEN)Packaging aic8800-firmware for $(BOARD)$(END_COLOUR)"
	@mkdir -p $(BUILDDIR)/package/firmware-aic8800-$(CHIP)-$(OSDRVVERSION)
	@cp -r /builder/deb/firmware-aic8800-cv181x/* $(BUILDDIR)/package/firmware-aic8800-$(CHIP)-$(OSDRVVERSION)/
	@mkdir -p $(BUILDDIR)/package/firmware-aic8800-$(CHIP)-$(OSDRVVERSION)/lib/firmware/aic8800_sdio/aic8800/
	@cp -a $(BUILDDIR)/aic8800-firmware/aic8800/SDIO/aic8800/ $(BUILDDIR)/package/firmware-aic8800-$(CHIP)-$(OSDRVVERSION)/lib/firmware/aic8800_sdio/
# 	This is the DUOS firmware
	@cp -a $(BUILDDIR)/aic8800-firmware/aic8800/SDIO/aic8800D80/* $(BUILDDIR)/package/firmware-aic8800-$(CHIP)-$(OSDRVVERSION)/lib/firmware/aic8800_sdio/aic8800/
	@sed -i 's/Version: 1.0.0/Version: $(OSDRVVERSION)/' $(BUILDDIR)/package/firmware-aic8800-$(CHIP)-$(OSDRVVERSION)/DEBIAN/control
	@sed -i 's/Package: firmware-aic8800-cv181x/Package: firmware-aic8800-$(CHIP)/' $(BUILDDIR)/package/firmware-aic8800-$(CHIP)-$(OSDRVVERSION)/DEBIAN/control
	@cd $(BUILDDIR)/package/ && dpkg-deb --build firmware-aic8800-$(CHIP)-$(OSDRVVERSION) firmware-aic8800-$(CHIP)_$(OSDRVVERSION)_$(DEB_ARCH).deb
	@cp $(BUILDDIR)/package/firmware-aic8800-$(CHIP)_$(OSDRVVERSION)_$(DEB_ARCH).deb /output/
	@mkdir -p /rootfs/tmp/install/
	@cp /output/firmware-aic8800-$(CHIP)*.deb /rootfs/tmp/install/
	@touch $@
