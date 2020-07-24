################################################################################
#
# explora-sdk
#
################################################################################
EXPLORA_SDK_VERSION = a12e275c5a9afd697aefaf865e02a2f1813e1b5a
EXPLORA_SDK_SITE = git@github.com:Metrological/SDK_Explora.git
EXPLORA_SDK_SITE_METHOD = git
EXPLORA_SDK_INSTALL_STAGING = YES

define EXPLORA_SDK_INSTALL_STAGING_CMDS
	$(INSTALL) -d $(STAGING_DIR)/usr/lib
	$(INSTALL) -D -m 0644 $(@D)/libs/* $(STAGING_DIR)/usr/lib/

	$(INSTALL) -d $(STAGING_DIR)/usr/lib/pkgconfig
	$(INSTALL) -D -m 0644 $(@D)/packages/* $(STAGING_DIR)/usr/lib/pkgconfig

	$(INSTALL) -d $(STAGING_DIR)/usr/include/refsw
	$(INSTALL) -d $(STAGING_DIR)/usr/include/widevine
	$(INSTALL) -d $(STAGING_DIR)/usr/include/EGL
	$(INSTALL) -d $(STAGING_DIR)/usr/include/KHR
	$(INSTALL) -d $(STAGING_DIR)/usr/include/GLES
	$(INSTALL) -d $(STAGING_DIR)/usr/include/GLES2
	cp -r $(@D)/includes/* $(STAGING_DIR)/usr/include
endef

define EXPLORA_SDK_INSTALL_TARGET_CMDS
#	$(INSTALL) -d $(TARGET_DIR)/usr/lib
#	$(INSTALL) -D -m 0644 $(@D)/libs/* $(TARGET_DIR)/usr/lib/
#	$(INSTALL) -d $(TARGET_DIR)/etc/init.d
#	$(INSTALL) -D -m 0750 $(@D)/bin/S40boxinfo $(TARGET_DIR)/etc/init.d
#	$(INSTALL) -d $(TARGET_DIR)/bin
#	$(INSTALL) -D -m 0750 $(@D)/bin/get_tlv_data.bin $(TARGET_DIR)/bin
#	$(INSTALL) -d $(TARGET_DIR)/lib/firmware
#	$(INSTALL) -D -m 0640 $(@D)/firmware/sage/release/* $(TARGET_DIR)/lib/firmware

	$(INSTALL) -D -m 0644 $(STAGING_DIR)/usr/lib/libv3ddriver.so $(TARGET_DIR)/usr/lib/
	$(INSTALL) -D -m 0644 $(STAGING_DIR)/usr/lib/libnxclient_local.so $(TARGET_DIR)/usr/lib/
	$(INSTALL) -D -m 0644 $(STAGING_DIR)/usr/lib/libnxclient.so $(TARGET_DIR)/usr/lib/
	rm $(TARGET_DIR)/usr/lib/libEGL.so
	rm $(TARGET_DIR)/usr/lib/libGLESv2.so 
	ln -s /usr/lib/libv3ddriver.so $(TARGET_DIR)/usr/lib/libEGL.so
	ln -s /usr/lib/libv3ddriver.so $(TARGET_DIR)/usr/lib/libGLESv2.so 
endef

$(eval $(generic-package))
