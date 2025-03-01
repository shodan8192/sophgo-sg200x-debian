$(BUILDDIR)/cvi-pinmux-stamp: $(BUILDDIR)/buildroot-package-stamp
	@echo "$(COLOUR_GREEN)Packaging cvi-pinmux for $(BOARD)$(END_COLOUR)"
	@$(eval CVIPINMUXVERSION=$(shell echo "1.0.0"))
	@$(eval BV=$(shell cd $(BUILDDIR)/buildroot && git log -1 --format="%at" | xargs -I{} date -d @{} +-%Y%m%d-${KERNELREV}))
	@mkdir -p $(BUILDDIR)/package/cvi-pinmux-cv181x-$(CVIPINMUXVERSION)
	@cp -r /builder/deb/cvi-pinmux-cv181x/* $(BUILDDIR)/package/cvi-pinmux-cv181x-$(CVIPINMUXVERSION)/
	@mkdir -pv $(BUILDDIR)/package/cvi-pinmux-cv181x-$(CVIPINMUXVERSION)/usr/bin/
	@cp -p $(BR_OUTPUT_DIR)/target/usr/bin/cvi-pinmux $(BUILDDIR)/package/cvi-pinmux-cv181x-$(CVIPINMUXVERSION)/usr/bin/cvi_pinmux
	@sed -i 's/Version: 1.0.0-1/Version: $(CVIPINMUXVERSION)$(BV)/' $(BUILDDIR)/package/cvi-pinmux-cv181x-$(CVIPINMUXVERSION)/DEBIAN/control
	@sed -i 's/Package: cvi-pinmux-cv181x/Package: cvi-pinmux-cv181x/' $(BUILDDIR)/package/cvi-pinmux-cv181x-$(CVIPINMUXVERSION)/DEBIAN/control
	@cd $(BUILDDIR)/package/ && dpkg-deb --build cvi-pinmux-cv181x-$(CVIPINMUXVERSION) cvi-pinmux-cv181x_$(CVIPINMUXVERSION)$(BV)_$(DEB_ARCH).deb
	@cp $(BUILDDIR)/package/cvi-pinmux-cv181x_$(CVIPINMUXVERSION)$(BV)_$(DEB_ARCH).deb /output/
	@mkdir -p /rootfs/tmp/install/
	@cp /output/cvi-pinmux-cv181x_$(CVIPINMUXVERSION)$(BV)_$(DEB_ARCH).deb /rootfs/tmp/install/
	@touch $@
