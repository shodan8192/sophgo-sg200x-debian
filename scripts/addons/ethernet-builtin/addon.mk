ifneq ("$(findstring ethernet-builtin,$(IMAGE_ADDITIONS))","")
BSPFILTER += "ethernet-builtin"
endif

$(BUILDDIR)/ethernet-builtin-stamp:
	@echo "$(COLOUR_GREEN)Installing ethernet-builtin for $(BOARD)$(END_COLOUR)"
	@mkdir -p /rootfs/etc/network/interfaces.d/
	@cp -a addons/ethernet-builtin/end0 /rootfs/etc/network/interfaces.d/
	@mkdir -p /rootfs/tmp/install/
	@touch $@
