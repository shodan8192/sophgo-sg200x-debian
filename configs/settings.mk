KERNELREV="6"
FSBLVERSION=1.1.0
BSPVERSION=1.0.30
OSDRVVERSION=2024.10.14
MIDDLEWAREVERSION=2024.10.14
PACKAGES="busybox-static ca-certificates debian-archive-keyring dosfstools binutils file tree sudo bash-completion u-boot-menu openssh-server dnsmasq-base libpam-systemd ppp libatomic1 libgomp1 libengine-pkcs11-openssl iptables lldpd psmisc systemd-timesyncd vim usbutils parted exfatprogs systemd-sysv i2c-tools net-tools ifupdown ethtool avahi-utils sudo gnupg rsync gpiod u-boot-tools libubootenv-tool python3-requests unzip wget"
ifeq ("$(findstring kvm,$(VARIANT))","")
PACKAGES += " network-manager"
endif

IMAGE_ADDITIONS="gadget-nic"