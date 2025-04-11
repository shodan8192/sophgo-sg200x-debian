ifneq ("$(findstring overlayfs-tools,$(IMAGE_ADDITIONS))$(findstring overlayfs-tools,$(PACKAGES))","")
BSPDEPENDS += overlayfs-tools
BSPFILTER += "overlayfs-tools"
endif

$(BUILDDIR)/overlayfs-tools-stamp: $(BUILDDIR)/buildroot-package-stamp
	@echo "$(COLOUR_GREEN)Packaging overlayfs-tools for $(BOARD)$(END_COLOUR)"
	@$(eval OVERLAYFSTOOLSVERSION=$(shell echo "2025.01"))
	@$(eval BV=$(shell cd $(BUILDDIR)/buildroot && git log -1 --format="%at" | xargs -I{} date -d @{} +-%Y%m%d-${KERNELREV}))
	@mkdir -p $(BUILDDIR)/package/overlayfs-tools-$(OVERLAYFSTOOLSVERSION)
	@cp -r /builder/deb/overlayfs-tools/* $(BUILDDIR)/package/overlayfs-tools-$(OVERLAYFSTOOLSVERSION)/
	@mkdir -pv $(BUILDDIR)/package/overlayfs-tools-$(OVERLAYFSTOOLSVERSION)/usr/bin/
	@cp -p $(BR_OUTPUT_DIR)/target/usr/bin/fsck.overlay $(BUILDDIR)/package/overlayfs-tools-$(OVERLAYFSTOOLSVERSION)/usr/bin/
	@cp -p $(BR_OUTPUT_DIR)/target/usr/bin/overlay $(BUILDDIR)/package/overlayfs-tools-$(OVERLAYFSTOOLSVERSION)/usr/bin/
	@sed -i 's/Version: 1.0.0-1/Version: $(OVERLAYFSTOOLSVERSION)$(BV)/' $(BUILDDIR)/package/overlayfs-tools-$(OVERLAYFSTOOLSVERSION)/DEBIAN/control
	@sed -i 's/Package: overlayfs-tools/Package: overlayfs-tools/' $(BUILDDIR)/package/overlayfs-tools-$(OVERLAYFSTOOLSVERSION)/DEBIAN/control
	@cd $(BUILDDIR)/package/ && dpkg-deb --build overlayfs-tools-$(OVERLAYFSTOOLSVERSION) overlayfs-tools_$(OVERLAYFSTOOLSVERSION)$(BV)_$(DEB_ARCH).deb
	@cp $(BUILDDIR)/package/overlayfs-tools_$(OVERLAYFSTOOLSVERSION)$(BV)_$(DEB_ARCH).deb /output/
	@mkdir -p /rootfs/tmp/install/
	@cp /output/overlayfs-tools_$(OVERLAYFSTOOLSVERSION)$(BV)_$(DEB_ARCH).deb /rootfs/tmp/install/
	@touch $@
