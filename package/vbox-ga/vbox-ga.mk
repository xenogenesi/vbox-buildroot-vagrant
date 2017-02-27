################################################################################
#
# virtual box guest additions (for guest)
#
################################################################################

VBOX_GA_VERSION = 5.1.14
VBOX_GA_SOURCE = vbox-guest-$(VBOX_GA_VERSION).tar.gz
# TODO find if there's a make variable for the current package directory
# (directory name and make variables prefix must match!)
VBOX_GA_SITE = $(BR2_EXTERNAL_VBOX_BUILDROOT_VAGRANT_PATH)/package/vbox-ga
VBOX_GA_SITE_METHOD = file
VBOX_GA_LICENSE = GPLv2
VBOX_GA_LICENSE_FILES = COPYING

# NOTE: export_modules from virtualbox sources
# the vbox-guest-5.1.14.tar.gz is manually built using VirtualBox sources
# (to avoid download the whole sources and save some disk space)
# modules sources are built using the script export_modules included on
# oracle's sources
# /src/VBox/Additions/linux/export_modules
# vbsfmount.c and mount.vboxsf.c are just a copy (as it is)

VBOX_GA_MODULE_SUBDIRS = src-$(VBOX_GA_VERSION)/modules
VBOX_GA_MODULE_MAKE_OPTS = KVERSION=$(LINUX_VERSION_PROBED)

$(eval $(kernel-module))

define VBOX_GA_BUILD_CMDS
	$(TARGET_CC) -Wall -O2 -D_GNU_SOURCE -DIN_RING3 \
		-I$(@D)/src-$(VBOX_GA_VERSION)/modules/vboxsf/include \
		-I$(@D)/src-$(VBOX_GA_VERSION)/modules/vboxsf \
		-o $(@D)/mount.vboxsf \
		$(@D)/src-$(VBOX_GA_VERSION)/mount.vboxsf/vbsfmount.c \
		$(@D)/src-$(VBOX_GA_VERSION)/mount.vboxsf/mount.vboxsf.c
endef

# modules already installed by modules_install

define VBOX_GA_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/mount.vboxsf \
		$(TARGET_DIR)/sbin
endef

define VBOX_GA_PERMISSIONS
	/sbin/mount.vboxsf  f  0755  0  0  -  -  -  -  -
endef

$(eval $(generic-package))
