################################################################################
#
# avs-device-sdk
#
################################################################################

AVS_DEVICE_SDK_VERSION = v1.15
AVS_DEVICE_SDK_SITE =  $(call github,alexa,avs-device-sdk,$(AVS_DEVICE_SDK_VERSION))
AVS_DEVICE_SDK_LICENSE = Apache-2.0
AVS_DEVICE_SDK_LICENSE_FILES = LICENSE.txt
AVS_DEVICE_SDK_INSTALL_STAGING = YES
AVS_DEVICE_SDK_DEPENDENCIES = host-cmake openssl libcurl sqlite

# SDK requires out of source building (SRCDIR != BUILDDIR)
AVS_DEVICE_SDK_SUBDIR = source
AVS_DEVICE_SDK_BUILDDIR = $(@D)/build

define AVS_DEVICE_SDK_EXTRACT_CMDS
	mkdir -p $(@D)/source
	$(TAR) --strip-components=1 $(TAR_OPTIONS) $(DL_DIR)/$(AVS_DEVICE_SDK_SOURCE) -C $(@D)/source
endef


ifeq ($(BR2_PACKAGE_AVS_DEVICE_SDK_BUILD_TYPE_DEBUG),y)
AVS_DEVICE_SDK_CONF_OPTS += -DCMAKE_BUILD_TYPE=DEBUG
endif

ifeq ($(BR2_PACKAGE_AVS_DEVICE_SDK_BUILD_GST_MEDIA_PLAYER),y)
AVS_DEVICE_SDK_DEPENDENCIES += gstreamer1 gst1-plugins-base gst1-plugins-good gst1-plugins-bad gst1-libav
AVS_DEVICE_SDK_CONF_OPTS += -DGSTREAMER_MEDIA_PLAYER=ON
endif

# ===================
# SAMPLE APPLICATION
# ===================
ifeq ($(BR2_PACKAGE_AVS_DEVICE_SDK_BUILD_SAMPLE_APP),y)
# to build sample app the -DGSTREAMER_MEDIA_PLAYER and -DPORTAUDIO must be enabled
AVS_DEVICE_SDK_DEPENDENCIES += gstreamer1 gst1-plugins-base gst1-plugins-good gst1-plugins-bad gst1-libav
AVS_DEVICE_SDK_CONF_OPTS += -DGSTREAMER_MEDIA_PLAYER=ON

ifeq ($(BR2_PACKAGE_AVS_DEVICE_SDK_MICROPHONE_BACKEND_PORTAUDIO),y)
AVS_DEVICE_SDK_DEPENDENCIES += portaudio
AVS_DEVICE_SDK_CONF_OPTS += -DPORTAUDIO=ON
AVS_DEVICE_SDK_CONF_OPTS += -DPORTAUDIO_LIB_PATH=$(TARGET_DIR)/usr/lib/libportaudio.so
AVS_DEVICE_SDK_CONF_OPTS += -DPORTAUDIO_INCLUDE_DIR=$(STAGING_DIR)/usr/include
endif # BR2_PACKAGE_AVS_DEVICE_SDK_MICROPHONE_BACKEND_PORTAUDIO

AVS_DEVICE_SDK_POST_INSTALL_TARGET_HOOKS += INSTALL_SAMPLE_APP
define INSTALL_SAMPLE_APP
	$(INSTALL) -D -m 0755 $(@D)/buildroot-build/SampleApp/src/SampleApp $(TARGET_DIR)/usr/bin/AVSSampleApp
endef # INSTALL_SAMPLE_APP

AVS_DEVICE_SDK_POST_INSTALL_TARGET_HOOKS += INSTALL_ALSA_CONFIG
define INSTALL_ALSA_CONFIG
	$(INSTALL) -D -m 0644 package/amazon-alexa/avs-device-sdk/asound.conf $(TARGET_DIR)/etc/asound.conf
endef

# TODO: provide secure method for delivering authorization config
AVS_DEVICE_SDK_POST_INSTALL_TARGET_HOOKS += CREATE_DB_AND_AUTH_CONFIG
define CREATE_DB_AND_AUTH_CONFIG
	$(INSTALL) -d $(TARGET_DIR)/etc/avs
	$(INSTALL) -d $(TARGET_DIR)/etc/avs/db
	$(@D)/source/tools/Install/genConfig.sh \
		$(@D)/source/tools/Install/config.json \
		2 \
		/etc/avs/db \
		$(@D)/source \
		$(@D)/buildroot-build/Integration/AlexaClientSDKConfig.json
	$(INSTALL) -D -m 0644 $(@D)/buildroot-build/Integration/AlexaClientSDKConfig.json $(TARGET_DIR)/etc/avs/
endef # CREATE_DB_AND_AUTH_CONFIG
endif # BR2_PACKAGE_AVS_DEVICE_SDK_BUILD_SAMPLE_APP

$(eval $(cmake-package))
