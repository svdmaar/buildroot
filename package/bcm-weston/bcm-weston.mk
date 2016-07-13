################################################################################
#
# bcm-weston
#
################################################################################

BCM_WESTON_VERSION = 5cea38fbcf3417ba6852350555dcff3f430ec69d
BCM_WESTON_SITE = git@github.com:Metrological/bcm-refsw.git
BCM_WESTON_SITE_METHOD = git
BCM_WESTON_DEPENDENCIES = bcm-refsw libffi host-expat expat libxkbcommon pixman libpng jpeg mtdev udev cairo libinput linux-pam libxml2
BCM_WESTON_LICENSE = PROPRIETARY
BCM_WESTON_INSTALL_STAGING = YES
BCM_WESTON_INSTALL_TARGET = YES

BCM_WESTON_CONF_OPTS += $(BCM_REFSW_CONF_OPTS)
BCM_WESTON_MAKE_ENV += $(BCM_REFSW_MAKE_ENV)

define BCM_WESTON_BUILD_WAYLAND
	$(HOST_CONFIGURE_OPTS) \
	$(BCM_WESTON_MAKE_ENV) \
	$(HOST_MAKE_ENV) \
		$(MAKE) -C $(@D)/AppLibs/opensource/wayland wayland-scanner -f Makefile.buildroot
	$(INSTALL) -m 755 -D $(@D)/AppLibs/opensource/wayland/build/wayland-scanner $(HOST_DIR)/usr/bin/wayland-scanner
	$(INSTALL) -m 0644 -D $(@D)/AppLibs/opensource/wayland/scanner/src/wayland-scanner.pc $(STAGING_DIR)/usr/lib/pkgconfig/wayland-scanner.pc
	$(SED) 's:^prefix=.*:prefix=/usr:' \
		-e 's:^wayland_scanner=.*:wayland_scanner=$(HOST_DIR)/usr/bin/wayland-scanner:' \
		$(STAGING_DIR)/usr/lib/pkgconfig/wayland-scanner.pc
	$(TARGET_CONFIGURE_OPTS) \
	$(BCM_WESTON_CONF_OPTS) \
	$(TARGET_MAKE_ENV) \
	$(BCM_WESTON_MAKE_ENV) \
		$(MAKE) -C $(@D)/AppLibs/opensource/wayland wayland -f Makefile.buildroot \
			TARGET_NAME=$(GNU_TARGET_NAME) HOST_NAME=$(GNU_HOST_NAME) \
			STAGING_DIR=$(STAGING_DIR) TARGET_DIR=$(TARGET_DIR)
endef

define BCM_WESTON_BUILD_NSC_PROTOCOL
	$(BCM_WESTON_MAKE_ENV) \
		$(MAKE) -C $(@D)/AppLibs/broadcom/weston/protocol -f Makefile.buildroot
endef

define BCM_WESTON_BUILD_NXPL_WAYLAND
	$(TARGET_CONFIGURE_OPTS) \
	$(BCM_WESTON_CONF_OPTS) \
	$(TARGET_MAKE_ENV) \
	$(BCM_WESTON_MAKE_ENV) \
		$(MAKE) -C $(@D)/AppLibs/broadcom/weston/nxpl-wayland -f Makefile.buildroot
	$(INSTALL) -D $(@D)/AppLibs/broadcom/weston/nxpl-wayland/libnxpl-weston.so $(STAGING_DIR)/usr/lib/
	$(INSTALL) -D $(@D)/AppLibs/broadcom/weston/nxpl-wayland/libnxpl-weston.so $(TARGET_DIR)/usr/lib/
endef

define BCM_WESTON_BUILD_WAYLAND_EGL
	$(TARGET_CONFIGURE_OPTS) \
	$(BCM_WESTON_CONF_OPTS) \
	$(TARGET_MAKE_ENV) \
	$(BCM_WESTON_MAKE_ENV) \
		$(MAKE) -C $(@D)/AppLibs/broadcom/weston/wayland-egl -f Makefile.buildroot \
			STAGING_DIR=$(STAGING_DIR)
	$(INSTALL) -D $(@D)/AppLibs/broadcom/weston/wayland-egl/libwayland-egl.so $(STAGING_DIR)/usr/lib/
	$(INSTALL) -m 644 -D $(@D)/AppLibs/broadcom/weston/wayland-egl/wayland-egl.pc $(STAGING_DIR)/usr/lib/pkgconfig/
	$(INSTALL) -m 644 -D $(@D)/AppLibs/broadcom/weston/wayland-egl/egl.pc $(STAGING_DIR)/usr/lib/pkgconfig/
	$(INSTALL) -D $(@D)/AppLibs/broadcom/weston/wayland-egl/libwayland-egl.so $(TARGET_DIR)/usr/lib/
endef

define BCM_WESTON_BUILD_WESTON
	$(TARGET_CONFIGURE_OPTS) \
	$(BCM_WESTON_CONF_OPTS) \
	$(TARGET_MAKE_ENV) \
	$(BCM_WESTON_MAKE_ENV) \
		$(MAKE) -C $(@D)/AppLibs/opensource/weston -f Makefile.buildroot \
			TARGET_NAME=$(GNU_TARGET_NAME) HOST_NAME=$(GNU_HOST_NAME) \
			STAGING_DIR=$(STAGING_DIR) TARGET_DIR=$(TARGET_DIR)
	mkdir -p $(TARGET_DIR)/usr/share/fonts
	cp -R $(@D)/AppLibs/opensource/fonts/* $(TARGET_DIR)/usr/share/fonts/
	cp -R $(@D)/AppLibs/broadcom/weston/data/* $(TARGET_DIR)/usr/share/weston/
endef

define BCM_WESTON_BUILD_NSC_BACKEND
	$(TARGET_CONFIGURE_OPTS) \
	$(BCM_WESTON_CONF_OPTS) \
	$(TARGET_MAKE_ENV) \
	$(BCM_WESTON_MAKE_ENV) \
		$(MAKE) -C $(@D)/AppLibs/broadcom/weston/weston/nsc-backend -f Makefile.buildroot \
			STAGING_DIR=$(STAGING_DIR) TARGET_DIR=$(TARGET_DIR)
endef

define BCM_WESTON_BUILD_CMDS
	$(BCM_WESTON_BUILD_WAYLAND)
	$(BCM_WESTON_BUILD_NSC_PROTOCOL)
	$(BCM_WESTON_BUILD_NXPL_WAYLAND)
	$(BCM_WESTON_BUILD_WAYLAND_EGL)
	$(BCM_WESTON_BUILD_WESTON)
	$(BCM_WESTON_BUILD_NSC_BACKEND)
endef

define BCM_WESTON_INSTALL_STAGING_CMDS
	$(INSTALL) -m 644 package/bcm-weston/egl.pc $(STAGING_DIR)/usr/lib/pkgconfig/egl.pc
	$(INSTALL) -m 644 package/bcm-weston/glesv2.pc $(STAGING_DIR)/usr/lib/pkgconfig/
endef

define BCM_WESTON_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 755 package/bcm-weston/S70weston $(TARGET_DIR)/etc/init.d/S70weston
endef

$(eval $(generic-package))
