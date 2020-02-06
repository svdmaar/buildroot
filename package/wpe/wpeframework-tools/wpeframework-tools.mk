################################################################################
#
# wpeframework-tools
#
################################################################################

WPEFRAMEWORK_TOOLS_VERSION = 4c5dd1175afad582809653385c6bfa21f191dfef

HOST_WPEFRAMEWORK_TOOLS_SITE = $(call github,WebPlatformForEmbedded,WPEFramework,$(WPEFRAMEWORK_TOOLS_VERSION))
HOST_WPEFRAMEWORK_TOOLS_INSTALL_STAGING = YES
HOST_WPEFRAMEWORK_TOOLS_INSTALL_TARGET = NO

HOST_WPEFRAMEWORK_TOOLS_DEPENDENCIES = host-cmake host-python-jsonref

HOST_WPEFRAMEWORK_TOOLS_SUBDIR = Tools

$(eval $(host-cmake-package))
