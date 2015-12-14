################################################################################
#
# phpmyadmin
#
################################################################################

# for mysql >= 5.5
#PHPMYADMIN_VERSION = 4.5.2 
#PHPMYADMIN_VERSION = 4.4.15.1
PHPMYADMIN_VERSION = 4.0.10.11
PHPMYADMIN_SOURCE = phpMyAdmin-$(PHPMYADMIN_VERSION)-english.tar.xz
PHPMYADMIN_SITE = http://files.phpmyadmin.net/phpMyAdmin/$(PHPMYADMIN_VERSION)

PHPMYADMIN_ROOTFS_DIR = /var/lib/phpmyadmin
PHPMYADMIN_TARGET_DIR = $(TARGET_DIR)$(PHPMYADMIN_ROOTFS_DIR)

define PHPMYADMIN_INSTALL_TARGET_CMDS
	mkdir -p $(PHPMYADMIN_TARGET_DIR)
	-rm -fr $(PHPMYADMIN_TARGET_DIR)/*
	cd $(@D); tar -cf - . | tar -C $(PHPMYADMIN_TARGET_DIR) -xf -
	sed -e "s/AllowNoPassword'] = false/AllowNoPassword'] = true/" \
		$(PHPMYADMIN_TARGET_DIR)/config.sample.inc.php \
		> $(PHPMYADMIN_TARGET_DIR)/config.inc.php
endef


define PHPMYADMIN_PERMISSIONS
	$(PHPMYADMIN_ROOTFS_DIR)  r  0755  33  33  -  -  -  -  -
endef

$(eval $(generic-package))
