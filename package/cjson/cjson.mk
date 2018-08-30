################################################################################
#
# cjson
#
################################################################################

ifeq ($(BR2_PACKAGE_CJSON_VERSION_1.7),y)
CJSON_VERSION = 3c8935676a97c7c97bf006db8312875b4f292f6c
CJSON_SITE =  git://github.com/DaveGamble/cJSON.git
else
CJSON_VERSION = v1.4.0
CJSON_SITE = $(call github,DaveGamble,cJSON,$(CJSON_VERSION))
endif

CJSON_INSTALL_STAGING = YES
CJSON_LICENSE = MIT
CJSON_LICENSE_FILES = LICENSE
# Set ENABLE_CUSTOM_COMPILER_FLAGS to OFF in particular to disable
# -fstack-protector-strong which depends on BR2_TOOLCHAIN_HAS_SSP
CJSON_CONF_OPTS += \
	-DENABLE_CJSON_TEST=OFF \
	-DENABLE_CUSTOM_COMPILER_FLAGS=OFF

$(eval $(cmake-package))
