################################################################################
#
# mlb (minimal linux bootloader)
#
################################################################################

MLB_VERSION = 61fdd07e2e05f6ef342ea55277f242dbfc940bda
MLB_SITE = https://github.com/xenogenesi/mlb.git
MLB_SITE_METHOD = git
MLB_LICENSE = GPLv3
MLB_LICENSE_FILES = LICENSE

define MLB_BUILD_CMDS
	$(MAKE) -C $(@D) all
endef

$(eval $(generic-package))
