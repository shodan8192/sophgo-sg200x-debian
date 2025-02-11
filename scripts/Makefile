COLOUR_GREEN=\n\033[0;32m
COLOUR_RED=\033[0;31m
COLOUR_BLUE=\033[0;34m
END_COLOUR=\033[0m\n

red:=$(shell tput setaf 1)
blue:=$(shell tput setaf 4)
reset:=$(shell tput sgr0)

BUILDDIR := /build/

CROSS_COMPILE_GLIBC_RISCV64 = riscv64-unknown-linux-gnu-
CROSS_COMPILE_MUSL_RISCV64 = riscv64-unknown-linux-musl-

CROSS_COMPILE_PATH_GLIBC_RISCV64 = /host-tools/gcc/riscv64-linux-x86_64
CROSS_COMPILE_PATH_MUSL_RISCV64 = /host-tools/gcc/riscv64-linux-musl-x86_64

SDK_VER = glibc_riscv64
SDK_CROSS_COMPILE_PATH = $(CROSS_COMPILE_PATH_GLIBC_RISCV64)
SDK_CROSS_COMPILE_PREFIX = $(CROSS_COMPILE_GLIBC_RISCV64)

OSDRV_ENV = CHIP_ARCH=CV181X \
CVIARCH=CV181X \
SDK_VER=$(SDK_VER) \
CROSS_COMPILE_GLIBC_RISCV64=$(CROSS_COMPILE_PATH_GLIBC_RISCV64)/bin/$(CROSS_COMPILE_GLIBC_RISCV64) \
CROSS_COMPILE_MUSL_RISCV64=$(CROSS_COMPILE_PATH_MUSL_RISCV64)/bin/$(CROSS_COMPILE_MUSL_RISCV64) \
CONFIG_ARCH=riscv \
CONFIG_CROSS_COMPILE_KERNEL="$(SDK_CROSS_COMPILE_PATH)/bin/$(SDK_CROSS_COMPILE_PREFIX)" \
CONFIG_CP_EXT_WIRELESS=y

SENSOR_ENV = CONFIG_SENSOR_GCORE_GC2083=y \
CONFIG_SENSOR_GCORE_GC4653=y \
CONFIG_SENSOR_OV_OS04A10=y \
CONFIG_SENSOR_OV_OV2685=y \
CONFIG_SENSOR_OV_OV5647=y \
CONFIG_SENSOR_SMS_SC035GS=y \
CONFIG_SENSOR_LONTIUM_LT6911=y

MIDDLEWARE_ENV = $(OSDRV_ENV) $(SENSOR_ENV)

BR_BOARD = cvitek_CV181X_$(SDK_VER)
BR_DEFCONFIG = $(BR_BOARD)_defconfig
BR_DIR = $(BUILDDIR)/buildroot
BR_OUTPUT_DIR = $(BR_DIR)/output/$(BR_BOARD)

BUILDROOT_ENV = CROSS_COMPILE_KERNEL=$(patsubst "%",%,$(SDK_CROSS_COMPILE_PREFIX)) \
CROSS_COMPILE_SDK=$(patsubst "%",%,$(SDK_CROSS_COMPILE_PREFIX)) \
TARGET_OUTPUT_DIR=$(BR_OUTPUT_DIR)

KO_DIRS = drivers/i2c \
drivers/input/touchscreen \
drivers/media/usb/gspca \
drivers/net/usb \
drivers/net/wireless \
drivers/pwm \
drivers/rtc \
drivers/spi \
drivers/video/backlight \
fs/efivarfs \
net/ipv4 \
net/wireless

ifndef BOARD
$(error $(red)BOARD is not set$(reset))
endif

include /configs/settings.mk

ifneq ("$(wildcard /configs/$(BOARD)/settings.mk)","")
include /configs/$(BOARD)/settings.mk
else
$(error $(red)Board $(BOARD) not supported$(reset))
endif

include $(wildcard /builder/addons/*/addon.mk)

addon-targets = $(patsubst "%,$(BUILDDIR)/%-stamp,$(patsubst %",%,$(IMAGE_ADDITIONS)))
_PACKAGES = $(patsubst "%,%,$(patsubst %",%,$(PACKAGES)))


$(info $(blue)Board: $(BOARD)$(reset))
$(info $(blue)Variant: $(VARIANT)$(reset))
$(info $(blue)Storage: $(STORAGE_TYPE)$(reset))
$(info $(blue)Image Addons: $(IMAGE_ADDITIONS)$(reset))
$(info $(blue)Packages: $(_PACKAGES)$(reset))

NPROCS := $(shell nproc)


define copy_header_action
	@cp -r $(BUILDDIR)/osdrv/interdrv/include/chip/cv181x/uapi/linux/* ${1}/linux/
	@cp -r $(BUILDDIR)/osdrv/interdrv/include/common/uapi/linux/* ${1}/linux/
	@cp $(BUILDDIR)/kernel/drivers/staging/android/uapi/ion.h ${1}/linux/
	@cp $(BUILDDIR)/kernel/drivers/staging/android/uapi/ion_cvitek.h ${1}/linux/
	@cp $(BUILDDIR)/kernel/include/uapi/linux/dma-buf.h ${1}/linux/
endef

define copy_ko_action
	@mkdir -p $(BUILDDIR)/osdrv/ko
	$(foreach kodir, $(KO_DIRS), find ${1}/lib/modules/*/kernel/$(kodir) -name '*.ko' -exec cp -f {} $(BUILDDIR)/osdrv/ko/ \; ;)
endef

$(BUILDDIR)/linux-prepare-checkout-stamp:
	@echo "$(COLOUR_GREEN)Checking out Kernel for $(BOARD)$(END_COLOUR)"
	@mkdir -p $(BUILDDIR)
	@git clone -b licheervnano-merged-5.10.y --depth 7 https://github.com/scpcom/linux.git /build/kernel
	@cd $(BUILDDIR)/kernel && git checkout c2b481a
	@touch $@

$(BUILDDIR)/linux-prepare-patch-stamp: $(BUILDDIR)/linux-prepare-checkout-stamp
	@echo "$(COLOUR_GREEN)Patching Kernel for $(BOARD)$(END_COLOUR)"
	@$(foreach file, $(wildcard /configs/common/patches/linux/*.patch), cd $(BUILDDIR)/kernel && git apply --ignore-whitespace $(file);)
	@$(foreach file, $(wildcard /configs/$(BOARD)/patches/linux/*.patch), cd $(BUILDDIR)/kernel && git apply --ignore-whitespace $(file);)
	@cp /configs/$(BOARD)/linux/defconfig $(BUILDDIR)/kernel/arch/riscv/configs/${BOARD}_defconfig
	@$(foreach file, $(wildcard /configs/common/dts/$(CHIP)/*), cp $(file) $(BUILDDIR)/kernel/arch/riscv/boot/dts/cvitek/;)
	@$(foreach file, $(wildcard /configs/common/dts/$(CHIP)_$(ARCH)/*), cp $(file) $(BUILDDIR)/kernel/arch/riscv/boot/dts/cvitek/;)
	@$(foreach file, $(wildcard /configs/$(BOARD)/dts/*), cp $(file) $(BUILDDIR)/kernel/arch/riscv/boot/dts/cvitek/;)
	@python3 /builder/python/mmap_conv.py --type h /configs/$(BOARD)/memmap.py $(BUILDDIR)/kernel/arch/riscv/boot/dts/cvitek/cvi_board_memmap.h
	@touch $@

$(BUILDDIR)/linux-prepare-configure-stamp: $(BUILDDIR)/linux-prepare-patch-stamp
	@echo "$(COLOUR_GREEN)Configuring Kernel for $(BOARD)$(END_COLOUR)"
	@cd $(BUILDDIR)/kernel KDEB_SOURCENAME=linux-sophgo  && $(MAKE) -j$(NPROCS) O=$(BUILDDIR)/kernel/ ARCH=riscv CROSS_COMPILE="$(SDK_CROSS_COMPILE_PATH)/bin/$(SDK_CROSS_COMPILE_PREFIX)" ${BOARD}_defconfig
	@$(eval LV=$(shell cd $(BUILDDIR)/kernel && git log -1 --format="%at" | xargs -I{} date -d @{} +-%Y%m%d-${KERNELREV}))
	@sed -i 's/CONFIG_LOCALVERSION=""/CONFIG_LOCALVERSION="$(LV)"/' $(BUILDDIR)/kernel/.config
	@touch $@

$(BUILDDIR)/linux-compile-stamp: $(BUILDDIR)/linux-prepare-configure-stamp
	@echo "$(COLOUR_GREEN)Building Kernel for $(BOARD)$(END_COLOUR)"
	@cd $(BUILDDIR)/kernel && KCFLAGS=-Wno-attribute-alias ARCH=riscv CROSS_COMPILE="$(SDK_CROSS_COMPILE_PATH)/bin/$(SDK_CROSS_COMPILE_PREFIX)" KDEB_SOURCENAME=linux-$(BOARD) LOCALVERSION=+$(BOARD) $(MAKE) -j$(NPROCS) O=$(BUILDDIR)/kernel/ bindeb-pkg
	@cd $(BUILDDIR)/kernel && KCFLAGS=-Wno-attribute-alias ARCH=riscv CROSS_COMPILE="$(SDK_CROSS_COMPILE_PATH)/bin/$(SDK_CROSS_COMPILE_PREFIX)" KDEB_SOURCENAME=linux-$(BOARD) LOCALVERSION=+$(BOARD) $(MAKE) -j$(NPROCS) O=$(BUILDDIR)/kernel/ modules_install INSTALL_MOD_PATH=$(BUILDDIR)/kernel/modules headers_install INSTALL_HDR_PATH=$(BUILDDIR)/kernel/riscv/usr
	@cp $(BUILDDIR)/*.deb /output/
	@touch $@

linux: $(BUILDDIR)/linux-compile-stamp

linux-clean:
	@rm -rf $(BUILDDIR)/kernel
	@rm -f $(BUILDDIR)/linux-*-stamp
	@rm -f $(BUILDDIR)/linux-*.deb


$(BUILDDIR)/osdrv-prepare-checkout-stamp:
	@echo "$(COLOUR_GREEN)Checking out OSdrv for $(BOARD)$(END_COLOUR)"
	@mkdir -p $(BUILDDIR)
	@git clone -b licheervnano-cvisdk --depth 7 https://github.com/scpcom/sophgo-osdrv.git /build/osdrv
	@cd $(BUILDDIR)/osdrv && git checkout bbb5269
	@touch $@

$(BUILDDIR)/osdrv-prepare-patch-stamp: $(BUILDDIR)/osdrv-prepare-checkout-stamp $(BUILDDIR)/linux-compile-stamp
	@echo "$(COLOUR_GREEN)Patching OSdrv for $(BOARD)$(END_COLOUR)"
	$(call copy_ko_action, $(BUILDDIR)/kernel/modules)
	@$(foreach file, $(wildcard /configs/common/patches/osdrv/*.patch), cd $(BUILDDIR)/osdrv && git apply --ignore-whitespace $(file);)
	@$(foreach file, $(wildcard /configs/$(BOARD)/patches/osdrv/*.patch), cd $(BUILDDIR)/osdrv && git apply --ignore-whitespace $(file);)
	@touch $@

$(BUILDDIR)/osdrv-prepare-configure-stamp: $(BUILDDIR)/osdrv-prepare-patch-stamp
	@echo "$(COLOUR_GREEN)Configuring OSdrv for $(BOARD)$(END_COLOUR)"
	@touch $@

$(BUILDDIR)/osdrv-compile-stamp: $(BUILDDIR)/osdrv-prepare-configure-stamp
	@echo "$(COLOUR_GREEN)Building OSdrv for $(BOARD)$(END_COLOUR)"
	@cd $(BUILDDIR)/osdrv && $(OSDRV_ENV) $(MAKE) KERNEL_DIR=$(BUILDDIR)/kernel INSTALL_DIR=$(BUILDDIR)/osdrv/ko all
	@touch $@

$(BUILDDIR)/osdrv-package-stamp: $(BUILDDIR)/osdrv-compile-stamp
	@echo "$(COLOUR_GREEN)Packaging OSdrv for $(BOARD)$(END_COLOUR)"
	@$(eval LV=$(shell cd $(BUILDDIR)/kernel && git log -1 --format="%at" | xargs -I{} date -d @{} +-%Y%m%d-${KERNELREV}))
	@mkdir -p $(BUILDDIR)/package/cvitek-osdrv-$(BOARD)-$(OSDRVVERSION)
	@cp -r /builder/deb/cvitek-osdrv/* $(BUILDDIR)/package/cvitek-osdrv-$(BOARD)-$(OSDRVVERSION)/
	@mkdir -pv /$(BUILDDIR)/package/cvitek-osdrv-$(BOARD)-$(OSDRVVERSION)/mnt/system/ko/
	@cp -p $(BUILDDIR)/osdrv/ko/*.ko /$(BUILDDIR)/package/cvitek-osdrv-$(BOARD)-$(OSDRVVERSION)/mnt/system/ko/
	@rm -f /$(BUILDDIR)/package/cvitek-osdrv-$(BOARD)-$(OSDRVVERSION)/mnt/system/ko/soph_clock_cooling.ko
	@rm -f /$(BUILDDIR)/package/cvitek-osdrv-$(BOARD)-$(OSDRVVERSION)/mnt/system/ko/soph_pwm.ko
	@rm -f /$(BUILDDIR)/package/cvitek-osdrv-$(BOARD)-$(OSDRVVERSION)/mnt/system/ko/soph_rtc.ko
	@rm -f /$(BUILDDIR)/package/cvitek-osdrv-$(BOARD)-$(OSDRVVERSION)/mnt/system/ko/soph_saradc.ko
	@rm -f /$(BUILDDIR)/package/cvitek-osdrv-$(BOARD)-$(OSDRVVERSION)/mnt/system/ko/soph_wdt.ko
	@mkdir -pv /$(BUILDDIR)/package/cvitek-osdrv-$(BOARD)-$(OSDRVVERSION)/mnt/system/ko/3rd/
	@cp -p $(BUILDDIR)/osdrv/ko/3rd/*.ko /$(BUILDDIR)/package/cvitek-osdrv-$(BOARD)-$(OSDRVVERSION)/mnt/system/ko/3rd/
	@sed -i 's/Version: 1.0.0/Version: $(OSDRVVERSION)$(LV)/' $(BUILDDIR)/package/cvitek-osdrv-$(BOARD)-$(OSDRVVERSION)/DEBIAN/control
	@sed -i 's/Package: cvitek-osdrv/Package: cvitek-osdrv-$(BOARD)/' $(BUILDDIR)/package/cvitek-osdrv-$(BOARD)-$(OSDRVVERSION)/DEBIAN/control
	@cd $(BUILDDIR)/package/ && dpkg-deb --build cvitek-osdrv-$(BOARD)-$(OSDRVVERSION) cvitek-osdrv-$(BOARD)_$(OSDRVVERSION)$(LV).deb
	@cp $(BUILDDIR)/package/cvitek-osdrv-$(BOARD)_$(OSDRVVERSION)$(LV).deb /output/
	@touch $@

osdrv: $(BUILDDIR)/osdrv-package-stamp

osdrv-clean:
	@rm -rf $(BUILDDIR)/osdrv
	@rm -f $(BUILDDIR)/osdrv-*-stamp


$(BUILDDIR)/middleware-prepare-checkout-stamp:
	@echo "$(COLOUR_GREEN)Checking out Middleware for $(BOARD)$(END_COLOUR)"
	@mkdir -p $(BUILDDIR)
	@git clone -b maix_mmf-cvisdk --depth 7 --recursive https://github.com/scpcom/sophgo-middleware.git /build/middleware
	@cd $(BUILDDIR)/middleware && git checkout 368ac05
	@touch $@

$(BUILDDIR)/middleware-prepare-patch-stamp: $(BUILDDIR)/middleware-prepare-checkout-stamp $(BUILDDIR)/osdrv-compile-stamp
	@echo "$(COLOUR_GREEN)Patching Middleware for $(BOARD)$(END_COLOUR)"
	@cd / && /builder/fix-thead-glibc-toolchain.sh
	mkdir -pv $(BUILDDIR)/kernel/riscv/usr/include/linux/
	$(call copy_header_action, $(BUILDDIR)/kernel/riscv/usr/include)
	@$(foreach file, $(wildcard /configs/common/patches/middleware/*.patch), cd $(BUILDDIR)/middleware && git apply --ignore-whitespace $(file);)
	@$(foreach file, $(wildcard /configs/$(BOARD)/patches/middleware/*.patch), cd $(BUILDDIR)/middleware && git apply --ignore-whitespace $(file);)
	sed -i 's|$$(ROOT_DIR)/../host-tools|/host-tools|g' $(BUILDDIR)/middleware/Makefile.param
	sed -i 's|^include $$(BUILD_PATH)/.config|-include $$(BUILD_PATH)/.config|g' $(BUILDDIR)/middleware/Makefile.param
	sed -i 's|^include $$(BUILD_PATH)/.config|-include $$(BUILD_PATH)/.config|g' $(BUILDDIR)/middleware/component/isp/Makefile
	sed -i 's|^include $$(BUILD_PATH)/.config|-include $$(BUILD_PATH)/.config|g' $(BUILDDIR)/middleware/component/isp/common/Makefile
	sed -i 's|^include $$(BUILD_PATH)/.config|-include $$(BUILD_PATH)/.config|g' $(BUILDDIR)/middleware/sample/common/Makefile
	@touch $@

$(BUILDDIR)/middleware-prepare-configure-stamp: $(BUILDDIR)/middleware-prepare-patch-stamp
	@echo "$(COLOUR_GREEN)Configuring Middleware for $(BOARD)$(END_COLOUR)"
	@touch $@

$(BUILDDIR)/middleware-compile-stamp: $(BUILDDIR)/middleware-prepare-configure-stamp
	@echo "$(COLOUR_GREEN)Building Middleware for $(BOARD)$(END_COLOUR)"
	@cd $(BUILDDIR)/middleware && $(MIDDLEWARE_ENV) $(MAKE) KERNEL_DIR=$(BUILDDIR)/kernel all -j$(NPROCS)
	@mkdir -pv $(BUILDDIR)/middleware/install/system/
	@cd $(BUILDDIR)/middleware && $(MIDDLEWARE_ENV) $(MAKE) KERNEL_DIR=$(BUILDDIR)/kernel install DESTDIR=$(BUILDDIR)/middleware/install/system
	@touch $@

$(BUILDDIR)/middleware-package-stamp: $(BUILDDIR)/middleware-compile-stamp
	@echo "$(COLOUR_GREEN)Packaging Middleware for $(BOARD)$(END_COLOUR)"
	@$(eval MV=$(shell cd $(BUILDDIR)/middleware && git log -1 --format="%at" | xargs -I{} date -d @{} +-%Y%m%d-${KERNELREV}))
	@mkdir -p $(BUILDDIR)/package/cvitek-middleware-$(BOARD)-$(MIDDLEWAREVERSION)
	@cp -r /builder/deb/cvitek-middleware/* $(BUILDDIR)/package/cvitek-middleware-$(BOARD)-$(MIDDLEWAREVERSION)/
	@mkdir -pv /$(BUILDDIR)/package/cvitek-middleware-$(BOARD)-$(MIDDLEWAREVERSION)/mnt/system/
	@rsync -avpPxH $(BUILDDIR)/middleware/install/system/ /$(BUILDDIR)/package/cvitek-middleware-$(BOARD)-$(MIDDLEWAREVERSION)/mnt/system/
	@sed -i 's/Version: 1.0.0/Version: $(MIDDLEWAREVERSION)$(MV)/' $(BUILDDIR)/package/cvitek-middleware-$(BOARD)-$(MIDDLEWAREVERSION)/DEBIAN/control
	@sed -i 's/Package: cvitek-middleware/Package: cvitek-middleware-$(BOARD)/' $(BUILDDIR)/package/cvitek-middleware-$(BOARD)-$(MIDDLEWAREVERSION)/DEBIAN/control
	@cd $(BUILDDIR)/package/ && dpkg-deb --build cvitek-middleware-$(BOARD)-$(MIDDLEWAREVERSION) cvitek-middleware-$(BOARD)_$(MIDDLEWAREVERSION)$(MV).deb
	@cp $(BUILDDIR)/package/cvitek-middleware-$(BOARD)_$(MIDDLEWAREVERSION)$(MV).deb /output/
	@touch $@

middleware: $(BUILDDIR)/middleware-package-stamp

middleware-clean:
	@rm -rf $(BUILDDIR)/middleware
	@rm -f $(BUILDDIR)/middleware-*-stamp


$(BUILDDIR)/buildroot-prepare-checkout-stamp:
	@echo "$(COLOUR_GREEN)Checking out Buildroot for $(BOARD)$(END_COLOUR)"
	@mkdir -p $(BUILDDIR)
	@git clone -b nanokvm-2024.05 --depth 7 --recursive https://github.com/scpcom/buildroot.git /build/buildroot
	@cd $(BR_DIR) && git checkout 350e6e0
	@touch $@

$(BUILDDIR)/buildroot-prepare-patch-stamp: $(BUILDDIR)/buildroot-prepare-checkout-stamp $(BUILDDIR)/middleware-compile-stamp
	@echo "$(COLOUR_GREEN)Patching Buildroot for $(BOARD)$(END_COLOUR)"
	@$(foreach file, $(wildcard /configs/common/patches/buildroot/*.patch), cd $(BR_DIR) && git apply --ignore-whitespace $(file);)
	@$(foreach file, $(wildcard /configs/$(BOARD)/patches/buildroot/*.patch), cd $(BR_DIR) && git apply --ignore-whitespace $(file);)
	@cp /configs/common/buildroot/defconfig $(BR_DIR)/configs/$(BR_DEFCONFIG)
	@echo 'BR2_TOOLCHAIN_EXTERNAL_PATH="'$(SDK_CROSS_COMPILE_PATH)'"' >> $(BR_DIR)/configs/$(BR_DEFCONFIG)
	@mkdir -pv /build/buildroot/board/cvitek/CV181X/overlay/usr/share/fw_vcodec
	@mkdir -pv /build/ramdisk/tools/cvi_pinmux
	@touch $@

$(BUILDDIR)/buildroot-prepare-configure-stamp: $(BUILDDIR)/buildroot-prepare-patch-stamp
	@echo "$(COLOUR_GREEN)Configuring Buildroot for $(BOARD)$(END_COLOUR)"
	@cd $(BR_DIR) && $(BUILDROOT_ENV) $(MAKE) $(BR_DEFCONFIG) BR2_TOOLCHAIN_EXTERNAL_PATH=$(SDK_CROSS_COMPILE_PATH)
	@touch $@

$(BUILDDIR)/buildroot-compile-stamp: $(BUILDDIR)/buildroot-prepare-configure-stamp
	@echo "$(COLOUR_GREEN)Building Buildroot for $(BOARD)$(END_COLOUR)"
	@cd $(BR_DIR) && $(BUILDROOT_ENV) $(MAKE) -j$(NPROCS) source
	@cd $(BR_DIR) && $(BUILDROOT_ENV) $(MAKE) -j$(NPROCS)
	@touch $@

$(BUILDDIR)/buildroot-package-stamp: $(BUILDDIR)/buildroot-compile-stamp
	@echo "$(COLOUR_GREEN)Packaging Buildroot for $(BOARD)$(END_COLOUR)"
	if [ -e $(BR_OUTPUT_DIR)/target/kvmapp/server/NanoKVM-Server ]; then \
		rm -f /output/nanokvm-latest.zip ; \
		cd $(BR_OUTPUT_DIR)/target ; \
		ln -s kvmapp latest ; \
		zip -r --symlinks /output/nanokvm-latest.zip latest/* ; \
		rm latest ; \
	fi
	@touch $@

buildroot: $(BUILDDIR)/buildroot-package-stamp

buildroot-clean:
	@rm -rf $(BUILDDIR)/buildroot
	@rm -f $(BUILDDIR)/buildroot-*-stamp


$(BUILDDIR)/uboot-prepare-checkout-stamp:
	@echo "$(COLOUR_GREEN)Checking out U-Boot for $(BOARD)$(END_COLOUR)"
	@mkdir -p $(BUILDDIR)
	@git clone -b licheervnano-cvisdk-2021.10 --depth 7 https://github.com/scpcom/u-boot $(BUILDDIR)/u-boot
	@cd $(BUILDDIR)/u-boot && git checkout ffe9723
	@touch $@

$(BUILDDIR)/uboot-prepare-patch-stamp: $(BUILDDIR)/uboot-prepare-checkout-stamp
	@echo "$(COLOUR_GREEN)Patching U-Boot for $(BOARD)$(END_COLOUR)"
	@$(foreach file, $(wildcard /configs/common/patches/u-boot/*.patch), cd $(BUILDDIR)/u-boot && git apply --ignore-whitespace $(file);)
	@$(foreach file, $(wildcard /configs/$(BOARD)/patches/u-boot/*.patch), cd $(BUILDDIR)/u-boot && git apply --ignore-whitespace $(file);)
	@cp /configs/$(BOARD)/u-boot/defconfig $(BUILDDIR)/u-boot/configs/$(BOARD)_defconfig
	@$(foreach file, $(wildcard /configs/common/dts/$(CHIP)/*), cp $(file) $(BUILDDIR)/u-boot/arch/riscv/dts/;)
	@$(foreach file, $(wildcard /configs/common/dts/$(CHIP)_$(ARCH)/*), cp $(file) $(BUILDDIR)/u-boot/arch/riscv/dts/;)
	@$(foreach file, $(wildcard /configs/$(BOARD)/dts/*), cp $(file) $(BUILDDIR)/u-boot/arch/riscv/dts/;)
	@cp /configs/$(BOARD)/u-boot/cvitek.h $(BUILDDIR)/u-boot/include/cvitek.h
	@cp /configs/$(BOARD)/u-boot/cvi_board_init.c $(BUILDDIR)/u-boot/board/cvitek/cvi_board_init.c
	@python3 /builder/python/mmap_conv.py --type h /configs/$(BOARD)/memmap.py $(BUILDDIR)/u-boot/include/cvi_board_memmap.h
	@python3 /builder/python/mkcvipart.py /configs/$(BOARD)/$(PARTITION_FILE) $(BUILDDIR)/u-boot/include/
	@python3 /builder/python/mk_imgHeader.py /configs/$(BOARD)/$(PARTITION_FILE) $(BUILDDIR)/u-boot/include/ 
	@touch $@

$(BUILDDIR)/uboot-prepare-configure-stamp: $(BUILDDIR)/uboot-prepare-patch-stamp
	@echo "$(COLOUR_GREEN)Configuring U-Boot for $(BOARD)$(END_COLOUR)"
	cd $(BUILDDIR)/u-boot/ && $(MAKE) -j$(NPROCS) BOARD=cv181x CONFIG_USE_DEFAULT_ENV=y STORAGE_TYPE=$(STORAGE_TYPE) CHIP=$(UBOOT_CHIP) CVIBOARD=$(UBOOT_BOARD) CROSS_COMPILE="$(SDK_CROSS_COMPILE_PATH)/bin/$(SDK_CROSS_COMPILE_PREFIX)" $(BOARD)_defconfig
	@touch $@

$(BUILDDIR)/uboot-compile-stamp: $(BUILDDIR)/uboot-prepare-configure-stamp
	@echo "$(COLOUR_GREEN)Building U-Boot for $(BOARD)$(END_COLOUR)"
	cd $(BUILDDIR)/u-boot/ && $(MAKE) -j$(NPROCS) BOARD=cv181x CONFIG_USE_DEFAULT_ENV=y STORAGE_TYPE=$(STORAGE_TYPE) CHIP=$(UBOOT_CHIP) CVIBOARD=$(UBOOT_BOARD) CROSS_COMPILE="$(SDK_CROSS_COMPILE_PATH)/bin/$(SDK_CROSS_COMPILE_PREFIX)"
	cd $(BUILDDIR)/u-boot/ && $(MAKE) -j$(NPROCS) BOARD=cv181x CONFIG_USE_DEFAULT_ENV=y STORAGE_TYPE=$(STORAGE_TYPE) CHIP=$(UBOOT_CHIP) CVIBOARD=$(UBOOT_BOARD) CROSS_COMPILE="$(SDK_CROSS_COMPILE_PATH)/bin/$(SDK_CROSS_COMPILE_PREFIX)" u-boot-initial-env
	@cp $(BUILDDIR)/u-boot/u-boot.bin $(BUILDDIR)
	@cp $(BUILDDIR)/u-boot/u-boot.dtb $(BUILDDIR)
	@cp $(BUILDDIR)/u-boot/u-boot-initial-env $(BUILDDIR)
	@touch $@

uboot: $(BUILDDIR)/uboot-compile-stamp

uboot-clean:
	@rm -rf $(BUILDDIR)/u-boot
	@rm -f $(BUILDDIR)/uboot-*-stamp


$(BUILDDIR)/opensbi-prepare-checkout-stamp:
	@echo "$(COLOUR_GREEN)Checking out OpenSBI for $(BOARD)$(END_COLOUR)"
	@mkdir -p $(BUILDDIR)
	@git clone -b licheervnano-cvisdk-0.9 --depth 7 https://github.com/scpcom/opensbi $(BUILDDIR)/opensbi
	@cd $(BUILDDIR)/opensbi && git checkout 9955579
#	git clone https://github.com/riscv-software-src/opensbi.git $(BUILDDIR)/opensbi
#	@cd $(BUILDDIR)/opensbi && git checkout a2b255b
	@touch $@


$(BUILDDIR)/opensbi-prepare-patch-stamp: $(BUILDDIR)/opensbi-prepare-checkout-stamp
	@echo "$(COLOUR_GREEN)Patching OpenSBI for $(BOARD)$(END_COLOUR)"
	@$(foreach file, $(wildcard /configs/common/patches/opensbi/*.patch), cd $(BUILDDIR)/opensbi && git apply --ignore-whitespace $(file);)
	@$(foreach file, $(wildcard /configs/$(BOARD)/patches/opensbi/*.patch), cd $(BUILDDIR)/opensbi && git apply --ignore-whitespace $(file);)
	@touch $@

$(BUILDDIR)/opensbi-compile-stamp: $(BUILDDIR)/opensbi-prepare-patch-stamp $(BUILDDIR)/uboot-compile-stamp
	@echo "$(COLOUR_GREEN)Building OpenSBI for $(BOARD)$(END_COLOUR)"
	@cd $(BUILDDIR)/opensbi && CROSS_COMPILE="$(SDK_CROSS_COMPILE_PATH)/bin/$(SDK_CROSS_COMPILE_PREFIX)" CHIP_ARCH=CV181X make PLATFORM=generic FW_FDT_PATH=$(BUILDDIR)/u-boot.dtb
	@cp $(BUILDDIR)/opensbi/build/platform/generic/firmware/fw_dynamic.bin $(BUILDDIR) 
	@touch $@

opensbi: $(BUILDDIR)/opensbi-compile-stamp

opensbi-clean:
	@rm -rf $(BUILDDIR)/opensbi
	@rm -f $(BUILDDIR)/opensbi-*-stamp


$(BUILDDIR)/fsbl-prepare-checkout-stamp:
	@echo "$(COLOUR_GREEN)Checking out FSBL for $(BOARD)$(END_COLOUR)"
	@mkdir -p $(BUILDDIR)
	@git clone -b licheervnano-cvisdk --depth 7 https://github.com/scpcom/sophgo-fsbl $(BUILDDIR)/fsbl
	@cd $(BUILDDIR)/fsbl && git checkout c225e81
	@touch $@

$(BUILDDIR)/fsbl-prepare-patch-stamp: $(BUILDDIR)/fsbl-prepare-checkout-stamp
	@echo "$(COLOUR_GREEN)Patching FSBL for $(BOARD)$(END_COLOUR)"
	$(foreach file, $(wildcard /configs/common/patches/fsbl/*.patch), cd $(BUILDDIR)/fsbl && git apply --ignore-whitespace $(file);)
	$(foreach file, $(wildcard /configs/$(BOARD)/patches/fsbl/*.patch), cd $(BUILDDIR)/fsbl && git apply --ignore-whitespace $(file);)
	@python3 /builder/python/mmap_conv.py --type h /configs/$(BOARD)/memmap.py $(BUILDDIR)/fsbl/plat/$(CHIP)/include/cvi_board_memmap.h
	@printf '\163\000\120\020\157\360\337\377' > $(BUILDDIR)/fsbl/blank.bin
	@touch $@

$(BUILDDIR)/fsbl-compile-stamp: $(BUILDDIR)/fsbl-prepare-patch-stamp $(BUILDDIR)/opensbi-compile-stamp $(BUILDDIR)/uboot-compile-stamp
	@echo "$(COLOUR_GREEN)Building FSBL for $(BOARD)$(END_COLOUR)"
	@cd $(BUILDDIR)/fsbl && OD_CLK_SEL=y $(MAKE) -j$(NPROCS) ARCH=$(ARCH) CHIP_ARCH=$(CHIP) BOOT_CPU=$(BOOT_CPU) DDR_CFG=$(DDR_CFG) RTOS_ENABLE_FREERTOS=y BLCP_2ND_PATH=$(BUILDDIR)/fsbl/blank.bin LOADER_2ND_PATH=$(BUILDDIR)/u-boot.bin \
    CROSS_COMPILE=$(SDK_CROSS_COMPILE_PATH)/bin/$(SDK_CROSS_COMPILE_PREFIX) 
	@cp $(BUILDDIR)/fsbl/build/$(CHIP)/fip.bin $(BUILDDIR)
	@touch $@

$(BUILDDIR)/fsbl-package-stamp: $(BUILDDIR)/fsbl-compile-stamp
	@echo "$(COLOUR_GREEN)Packaging FSBL for $(BOARD)$(END_COLOUR)"
	@mkdir -p $(BUILDDIR)/package/cvitek-fsbl-$(BOARD)-$(FSBLVERSION)
	@cp -r /builder/deb/cvitek-fsbl/* $(BUILDDIR)/package/cvitek-fsbl-$(BOARD)-$(FSBLVERSION)/
	@mkdir -p $(BUILDDIR)/package/cvitek-fsbl-$(BOARD)-$(FSBLVERSION)/boot/ $(BUILDDIR)/package/cvitek-fsbl-$(BOARD)-$(FSBLVERSION)/etc/
	@cp $(BUILDDIR)/fip.bin $(BUILDDIR)/package/cvitek-fsbl-$(BOARD)-$(FSBLVERSION)/boot/
	@cp $(BUILDDIR)/u-boot-initial-env $(BUILDDIR)/package/cvitek-fsbl-$(BOARD)-$(FSBLVERSION)/etc/
	@sed -i 's/Version: 1.0.0/Version: $(FSBLVERSION)/' $(BUILDDIR)/package/cvitek-fsbl-$(BOARD)-$(FSBLVERSION)/DEBIAN/control
	@sed -i 's/Package: cvitek-fsbl/Package: cvitek-fsbl-$(BOARD)/' $(BUILDDIR)/package/cvitek-fsbl-$(BOARD)-$(FSBLVERSION)/DEBIAN/control
	@cd $(BUILDDIR)/package/ && dpkg-deb --build cvitek-fsbl-$(BOARD)-$(FSBLVERSION) cvitek-fsbl-$(BOARD)_$(FSBLVERSION).deb
	@cp $(BUILDDIR)/package/cvitek-fsbl-$(BOARD)_$(FSBLVERSION).deb /output/
	@touch $@

fsbl: $(BUILDDIR)/fsbl-package-stamp

fsbl-clean:
	@rm -rf $(BUILDDIR)/fsbl
	@rm -rf $(BUILDDIR)/package/cvitek-fsbl-*
	@rm -f $(BUILDDIR)/fsbl-*-stamp


$(BUILDDIR)/image-prepare-stamp: 
	@echo "$(COLOUR_GREEN)Preparing Image for $(BOARD)$(END_COLOUR)"
	@-mkdir $(BUILDDIR)
	@rm -rf /rootfs/
	@-rm $(addon-targets)
	@mkdir -p /rootfs/
	@curl -v -L https://sophgo.my-ho.st/public-key.asc -o $(BUILDDIR)/public-key.asc
	@mmdebstrap -v --architectures=riscv64 --include="$(_PACKAGES)" noble "/rootfs/" "deb http://ports.ubuntu.com/ubuntu-ports/ noble main universe" "deb [signed-by=$(BUILDDIR)/public-key.asc] https://sophgo.my-ho.st:8443/ debian sophgo"
	@touch $@

$(BUILDDIR)/image-addons-stamp: $(BUILDDIR)/image-prepare-stamp $(BUILDDIR)/fsbl-package-stamp $(BUILDDIR)/linux-compile-stamp $(BUILDDIR)/osdrv-package-stamp $(BUILDDIR)/middleware-package-stamp $(addon-targets)
	@[ -e /rootfs/usr/bin/devmem ] || ln -s busybox /rootfs/usr/bin/devmem
	@echo "$(COLOUR_GREEN)Copying Deb files for installation on $(BOARD)$(END_COLOUR)"
	@cp /output/cvitek-fsbl-$(BOARD)_*.deb /rootfs/tmp/install/
	@cp /output/cvitek-osdrv-$(BOARD)_*.deb /rootfs/tmp/install/
	@cp /output/cvitek-middleware-$(BOARD)_*.deb /rootfs/tmp/install/
	@cp /output/linux-image-*$(BOARD)*.deb /rootfs/tmp/install/
	@cp /output/linux-headers-*.deb /rootfs/tmp/install/
	@cp /output/linux-libc-dev*.deb /rootfs/tmp/install/
	@[ "X$(findstring kvm,$(VARIANT))" = "X" ] || cp /output/nanokvm-$(BOARD)_*.deb /rootfs/tmp/install/
	@touch $@


$(BUILDDIR)/image-customize-stamp: $(BUILDDIR)/image-addons-stamp $(BUILDDIR)/linux-compile-stamp $(BUILDDIR)/fsbl-package-stamp
	@echo "$(COLOUR_GREEN)Customizing Image for $(BOARD)$(END_COLOUR)"
	@mkdir -p /rootfs/tmp/install/
	@echo $(BOARD) > /rootfs/tmp/install/hostname
	@echo $(BOARD) > /rootfs/tmp/install/board
	@echo $(VARIANT) > /rootfs/tmp/install/variant
	@echo $(STORAGE_TYPE) > /rootfs/tmp/install/storage
	@cp -v /usr/bin/qemu-riscv64-static /rootfs/tmp/install/
	@cp -v /builder/setup_rootfs.sh /rootfs/tmp/install/
	@cp -v $(BUILDDIR)/public-key.asc /rootfs/tmp/install/
	@chroot /rootfs/ /tmp/install/qemu-riscv64-static /bin/sh /tmp/install/setup_rootfs.sh
	@rm -rf /rootfs/tmp/install/
	@umount /rootfs/proc || true 
	@umount /rootfs/sys || true 
	@umount /rootfs/run || true 
	@umount /rootfs/dev || true
	@touch $@

$(BUILDDIR)/image-compile-stamp: $(BUILDDIR)/image-customize-stamp
	@echo "$(COLOUR_GREEN)Compiling Image for $(BOARD)$(END_COLOUR)"
	@rm -rf /tmp/genimage/
	@cd $(BUILDDIR) && genimage --config /builder/genimage_$(STORAGE_TYPE).cfg --tmppath /tmp/genimage --rootpath /rootfs/
	@rm -rf /tmp/genimage/
	@if [ "$(STORAGE_TYPE)" = "emmc" ]; then \
		python3 /builder/python/raw2cimg.py -v $(BUILDDIR)/images/sdcard.img $(BUILDDIR)/images /configs/$(BOARD)/partition_emmc.xml; \
		mkdir -p /tmp/rom/; \
		cp $(BUILDDIR)/images/sdcard.img /tmp/rom/; \
		cp /configs/$(BOARD)/partition_emmc.xml /tmp/rom/; \
		cp $(BUILDDIR)/fip.bin /tmp/rom/; \
		cd /tmp && zip $(BOARD)_$(STORAGE_TYPE).zip -r rom/; \
		cp /tmp/$(BOARD)_$(STORAGE_TYPE).zip /output/; \
		echo "$(COLOUR_GREEN)Image for $(BOARD) is $(BOARD)_$(STORAGE_TYPE).zip$(END_COLOUR)"; \
	else \
		cp $(BUILDDIR)/images/sdcard.img /output/$(BOARD)_$(STORAGE_TYPE).img; \
		echo "$(COLOUR_GREEN)Image for $(BOARD) is $(BOARD)_$(STORAGE_TYPE).img$(END_COLOUR)"; \
	fi 
	@touch $@

image: $(BUILDDIR)/image-compile-stamp

image-clean:
	@rm -rf /rootfs/
	@rm -f $(BUILDDIR)/image-*-stamp $(addon-targets)
	@rm -f /output/$(BOARD)_$(STORAGE_TYPE).img

image-clean-customize:
	@rm -f $(BUILDDIR)/image-customize-stamp

clean: opensbi-clean uboot-clean linux-clean osdrv-clean middleware-clean fsbl-clean

.PHONY: image clean opensbi uboot linux osdrv middleware fsbl fsbl-clean uboot-clean linux-clean opensbi-clean
