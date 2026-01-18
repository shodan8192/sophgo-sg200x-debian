ifneq ("$(findstring nanokvm-pro,$(IMAGE_ADDITIONS))","")
BSPFILTER += "nanokvm-pro"
endif

NANOKVM_PRO_STABLE_URL = https://cdn.sipeed.com/nanokvm
NANOKVM_PRO_BASE_URL ?= $(NANOKVM_PRO_STABLE_URL)

$(BUILDDIR)/nanokvm-pro/nanokvm_pro_latest.json:
	@mkdir -p $(BUILDDIR)/nanokvm-pro
	@cd $(BUILDDIR)/nanokvm-pro ; wget -q -O nanokvm_pro_latest.json "$(NANOKVM_PRO_BASE_URL)/nanokvm_pro_latest.json?now=$(shell date +%s)"

$(BUILDDIR)/nanokvm-pro-stamp: $(BUILDDIR)/nanokvm-pro/nanokvm_pro_latest.json
	@echo "$(COLOUR_GREEN)Installing nanokvm-pro for $(BOARD)$(END_COLOUR)"
	@mkdir -p /rootfs/boot/
	@cp -p addons/nanokvm-pro/configs /rootfs/boot/
	@touch /rootfs/boot/check_resize2fs
	@touch /rootfs/boot/first_time_boot
	@touch /rootfs/boot/usb.ncm
	@mkdir -p $(BUILDDIR)/nanokvm-pro
	@$(eval NANOKVM_PRO_LATEST_FILE=$(shell cat $(BUILDDIR)/nanokvm-pro/nanokvm_pro_latest.json | jq -c '.name' | cut -d '"' -f 2))
	@cd $(BUILDDIR)/nanokvm-pro ; wget -N "$(NANOKVM_PRO_BASE_URL)/$(NANOKVM_PRO_LATEST_FILE)"
	@cd $(BUILDDIR)/nanokvm-pro ; tar xzf "$(NANOKVM_PRO_LATEST_FILE)"
	@cd $(BUILDDIR)/nanokvm-pro/nanokvm_pro_* ; [ "$(DEB_DISTRO)" != "trixie" ] || wget -N http://launchpadlibrarian.net/723774273/libjpeg-turbo8_2.1.5-2ubuntu2_arm64.deb
	@cp -p $(BUILDDIR)/nanokvm-pro/nanokvm_pro_*/*.deb /output/
	@mkdir -p /rootfs/tmp/install/
	@cp -p $(BUILDDIR)/nanokvm-pro/nanokvm_pro_*/*.deb /rootfs/tmp/install/
	@mkdir -pv /rootfs/boot/
	@echo kvm > /rootfs/boot/hostname.prefix
	@touch $@
