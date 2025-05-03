CHIP=cv181x
UBOOT_CHIP=cv181x
UBOOT_BOARD=licheea53nano_sd
BOOT_CPU=aarch64
ARCH=arm64
DDR_CFG=ddr3_1866_x16
ifneq ("$(findstring kvm,$(VARIANT))","")
BOARD_EXT=$(BOARD)-$(VARIANT)
ION_SIZE=35
else
ION_SIZE=63
endif
PARTITION_FILE=partition_sd.xml
STORAGE_TYPE=sd
VARIANT?=e

PACKAGES += " hostapd udhcpd wireless-regdb wpasupplicant"

IMAGE_ADDITIONS += "sensor-config"
IMAGE_ADDITIONS += "device-key"
IMAGE_ADDITIONS += "ethernet-builtin"
IMAGE_ADDITIONS += "load-systemko"
IMAGE_ADDITIONS += "cvi-pinmux"
ifneq ("$(findstring kvm,$(VARIANT))","")
IMAGE_ADDITIONS += "nanokvm"
else
IMAGE_ADDITIONS += "tpusdk"
endif
IMAGE_ADDITIONS += "usb-device"
IMAGE_ADDITIONS += "zram-config"
IMAGE_ADDITIONS += "wifi-builtin"
IMAGE_ADDITIONS += "aic8800-firmware"