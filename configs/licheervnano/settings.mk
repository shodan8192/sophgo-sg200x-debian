CHIP=cv181x
UBOOT_CHIP=cv181x
UBOOT_BOARD=licheervnano_sd
BOOT_CPU=riscv
ARCH=riscv
DDR_CFG=ddr3_1866_x16
ifneq ("$(findstring kvm,$(VARIANT))","")
ION_SIZE=35
else
ION_SIZE=63
endif
PARTITION_FILE=partition_sd.xml
STORAGE_TYPE=sd
VARIANT?=e

PACKAGES += " hostapd udhcpd wireless-regdb wpasupplicant cvi-pinmux-cv181x"

IMAGE_ADDITIONS += "device-config"
IMAGE_ADDITIONS += "device-key"
IMAGE_ADDITIONS += "ethernet-builtin"
IMAGE_ADDITIONS += "load-systemko"
ifneq ("$(findstring kvm,$(VARIANT))","")
IMAGE_ADDITIONS += "cvi-pinmux"
IMAGE_ADDITIONS += "nanokvm"
endif
IMAGE_ADDITIONS += "usb-device"
IMAGE_ADDITIONS += "wifi-builtin"
IMAGE_ADDITIONS += "aic8800-firmware"