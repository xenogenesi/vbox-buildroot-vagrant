################################################################################
#
# mlb (minimal linux bootloader)
#
################################################################################

MLB_VERSION = 471ca9b3048ecb8e820333c737424a2c361d0569
MLB_SITE = https://github.com/xenogenesi/mlb.git
MLB_SITE_METHOD = git
MLB_LICENSE = GPLv3
MLB_LICENSE_FILES = LICENSE

define MLB_BUILD_CMDS
	$(MAKE) -C $(@D) all
endef

$(eval $(generic-package))
