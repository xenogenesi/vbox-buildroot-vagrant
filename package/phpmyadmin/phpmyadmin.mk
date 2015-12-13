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

# $(INSTALL) -D -m 0755 $(@D)/mount.vboxsf \
# 	$(TARGET_DIR)/sbin

define PHPMYADMIN_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)/usr/htdocs/phpmyadmin
	-rm -fr $(TARGET_DIR)/usr/htdocs/phpmyadmin/*
	cd $(@D); tar -cf - . | tar -C $(TARGET_DIR)/usr/htdocs/phpmyadmin -xf -
	#cp $(TARGET_DIR)/usr/htdocs/phpmyadmin/config.sample.inc.php $(TARGET_DIR)/usr/htdocs/phpmyadmin/config.inc.php
	sed -e 's/AllowNoPassword'] = false/AllowNoPassword'] = true/' \
		$(TARGET_DIR)/usr/htdocs/phpmyadmin/config.sample.inc.php \
		> $(TARGET_DIR)/usr/htdocs/phpmyadmin/config.inc.php
endef


define PHPMYADMIN_PERMISSIONS
	/usr/htdocs/phpmyadmin  r  0755  33  33  -  -  -  -  -
endef

$(eval $(generic-package))
