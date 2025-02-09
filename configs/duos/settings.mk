CHIP=cv181x
STORAGE_TYPE?=sd
VARIANT?=e
UBOOT_CHIP=cv181x
UBOOT_BOARD=milkv_duos_$(STORAGE_TYPE)
BOOT_CPU=riscv
ARCH=riscv
DDR_CFG=ddr3_1866_x16
PARTITION_FILE=partition_$(STORAGE_TYPE).xml

PACKAGES += " duo-pinmux hostapd udhcpd wireless-regdb wpasupplicant cvi-pinmux-cv181x bluez"

IMAGE_ADDITIONS += "device-config"
IMAGE_ADDITIONS += "device-key"
IMAGE_ADDITIONS += "ethernet-builtin"
IMAGE_ADDITIONS += "load-systemko"
IMAGE_ADDITIONS += "aic8800-firmware"
IMAGE_ADDITIONS += "ethernet-leds"
IMAGE_ADDITIONS += "usb-switch"
IMAGE_ADDITIONS += "hciattach-service"