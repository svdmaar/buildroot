################################################################################
#
# alexa-smart-screen-sdk
#
################################################################################

ALEXA_SMART_SCREEN_SDK_VERSION = v2.0.1
ALEXA_SMART_SCREEN_SDK_SITE =  $(call github,alexa,alexa-smart-screen-sdk,$(ALEXA_SMART_SCREEN_SDK_VERSION))
ALEXA_SMART_SCREEN_SDK_LICENSE = Apache-2.0
ALEXA_SMART_SCREEN_SDK_LICENSE_FILES = LICENSE.txt
ALEXA_SMART_SCREEN_SDK_INSTALL_STAGING = YES
ALEXA_SMART_SCREEN_SDK_DEPENDENCIES = host-cmake apl-core-library avs-device-sdk websocketpp asio

# SDK requires out of source building (SRCDIR != BUILDDIR)
ALEXA_SMART_SCREEN_SDK_SUBDIR = source
ALEXA_SMART_SCREEN_SDK_BUILDDIR = $(@D)/build

define ALEXA_SMART_SCREEN_SDK_EXTRACT_CMDS
	mkdir -p $(@D)/source
	$(TAR) --strip-components=1 $(TAR_OPTIONS) $(DL_DIR)/$(ALEXA_SMART_SCREEN_SDK_SOURCE) -C $(@D)/source
endef

ifeq ($(BR2_PACKAGE_AVS_DEVICE_SDK_BUILD_TYPE_DEBUG),y)
ALEXA_SMART_SCREEN_SDK_CONF_OPTS += -DCMAKE_BUILD_TYPE=DEBUG
ALEXA_SMART_SCREEN_SDK_CONF_OPTS += -DDISABLE_WEBSOCKET_SSL=ON
endif

ALEXA_SMART_SCREEN_SDK_CONF_OPTS += -DWEBSOCKETPP_INCLUDE_DIR=$(STAGING_DIR)/usr/include/websocketpp
ALEXA_SMART_SCREEN_SDK_CONF_OPTS += -DAPL_CORE=ON

ifeq ($(BR2_PACKAGE_ALEXA_SMART_SCREEN_SDK_ENABLE_JS_GUICLIENT),y)
ALEXA_SMART_SCREEN_SDK_CONF_OPTS += -DJS_GUICLIENT_ENABLE=ON
ALEXA_SMART_SCREEN_SDK_CONF_OPTS += -DJS_GUICLIENT_INSTALL_PATH="$(TARGET_DIR)/$(call qstrip,$(BR2_PACKAGE_ALEXA_SMART_SCREEN_SDK_JS_GUICLIENT_INSTALL_PATH))"
endif

# ALEXA_SMART_SCREEN_SDK_POST_INSTALL_STAGING_HOOKS += INSTALL_HEADERS
# define INSTALL_HEADERS
# 	$(INSTALL) -d $(STAGING_DIR)/usr/include
# 	cp -ar $(@D)/source/modules/Alexa/Utils/include/Utils $(STAGING_DIR)/usr/include/
# endef

$(eval $(cmake-package))
