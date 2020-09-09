################################################################################
#
# netflix5.2
#
################################################################################

NETFLIX52_VERSION = 1ea6197bff6b73c96c86b9207c54114690ed8ab2
NETFLIX52_SITE = git@github.com:Metrological/netflix.git
NETFLIX52_SITE_METHOD = git
NETFLIX52_LICENSE = PROPRIETARY
NETFLIX52_DEPENDENCIES = freetype icu openjpeg lcms2 jpeg libpng libmng webp harfbuzz expat openssl c-ares nghttp2 libcurl graphite2 gstreamer1 gst1-plugins-base gst1-plugins-bad tremor
NETFLIX52_INSTALL_TARGET = YES
NETFLIX52_SUBDIR = netflix
NETFLIX52_RESOURCE_LOC = $(call qstrip,${BR2_PACKAGE_NETFLIX52_RESOURCE_LOCATION})

NETFLIX52_CONF_ENV += TOOLCHAIN_DIRECTORY=$(STAGING_DIR)/usr LD=$(TARGET_CROSS)ld
NETFLIX_CONF_ENV += TARGET_CROSS="$(GNU_TARGET_NAME)-"

NETFLIX52_CONF_OPTS += -DBUILD_REFERENCE=${NETFLIX52_VERSION}

# TODO: check if all args are really needed.
NETFLIX52_CONF_OPTS = \
	-DBUILD_GIBBON_DIRECTORY=$(@D)/partner/gibbon \
	-DBUILD_DPI_DIRECTORY=$(@D)/partner/dpi \
	-DCMAKE_INSTALL_PREFIX=$(@D)/release \
	-DCMAKE_OBJCOPY="$(TARGET_CROSS)objcopy" \
	-DCMAKE_STRIP="$(TARGET_CROSS)strip" \
	-DBUILD_COMPILE_RESOURCES=ON \
	-DBUILD_SYMBOLS=OFF \
	-DBUILD_SHARED_LIBS=OFF \
	-DNRDP_HAS_IPV6=ON \
	-DNRDP_CRASH_REPORTING="off" \
	-DBUILD_DEBUG=OFF -DNRDP_HAS_GIBBON_QA=ON -DNRDP_HAS_MUTEX_STACK=ON -DNRDP_HAS_OBJECTCOUNT=ON \
	-DBUILD_PRODUCTION=OFF -DNRDP_HAS_QA=OFF -DBUILD_SMALL=OFF -DBUILD_SYMBOLS=ON -DNRDP_HAS_TRACING=OFF \
	-DNRDP_CRASH_REPORTING=breakpad \
	-DGIBBON_GRAPHICS_GL_WSYS=egl \
	-DNRDP_SYSTEM_PROCESSOR=$(BR2_ARCH) \
	-DDPI_REFERENCE_DRM_NULL=TRUE \
	-DNRDP_HAS_SOFTWAREPLAYER=OFF \
	-DGIBBON_SOFTWARECAPTURE=OFF \
	-DGIBBON_GRAPHICS_GL_API="gles2" \
	-DDPI_IMPLEMENTATION=gstreamer \
	-DJS_MINIFY=OFF \
	-DDPI_DRM=ocdm \
	-DNRDP_TOOLS="provisioning" \
	-DNRDP_HAS_AUDIOMIXER=OFF

# DNRDP_TOOLS="provisioning" above for NF 5.2.2 requires update of openssl to ver >= 1.1.0
# which does not work out of the box. Since provisioning tools does not seem to be required for us
# default of BR2_PACKAGE_NETFLIX52_DISABLE_TOOLS is y.

ifeq ($(BR2_PACKAGE_NETFLIX52_DISABLE_TOOLS), y)
NETFLIX52_CONF_OPTS += \
	-DNRDP_TOOLS=none
endif

ifeq ($(BR2_PACKAGE_NETFLIX52_LIB), y)
NETFLIX52_INSTALL_STAGING = YES
NETFLIX52_CONF_OPTS += -DGIBBON_MODE=shared
NETFLIX52_FLAGS = -O3 -fPIC
else
NETFLIX52_CONF_OPTS += -DGIBBON_MODE=executable
endif

ifeq ($(BR2_PACKAGE_NETFLIX52_AUDIO_MIXER), y)
NETFLIX52_DEPENDENCIES += libogg tremor
ifeq ($(BR2_PACKAGE_NETFLIX52_AUDIO_MIXER_SOFTWARE), y)
NETFLIX52_CONF_OPTS += -DNRDP_HAS_AUDIOMIXER=ON \
                      -DUSE_AUDIOMIXER_GST=ON
else ifeq ($(BR2_PACKAGE_NETFLIX52_AUDIO_MIXER_NEXUS), y)
NETFLIX52_CONF_OPTS += -DNRDP_HAS_AUDIOMIXER=ON \
                      -DUSE_AUDIOMIXER_NEXUS=ON
endif
endif

ifeq ($(BR2_PACKAGE_WPEFRAMEWORK_COMPOSITORCLIENT),y)
NETFLIX52_CONF_OPTS += -DGIBBON_GRAPHICS=wpeframework
NETFLIX52_CONF_OPTS += -DGIBBON_INPUT=wpeframework
NETFLIX52_CONF_OPTS += -DGIBBON_PLATFORM=posix 
NETFLIX52_DEPENDENCIES += wpeframework
endif

ifeq ($(BR2_PACKAGE_NETFLIX52_WESTEROS_SINK),y)
  NETFLIX52_CONF_OPTS += -DGST_VIDEO_RENDERING=westeros
  NETFLIX52_DEPENDENCIES += westeros westeros-sink
endif

NETFLIX52_DEPENDENCIES += libgles libegl

ifeq ($(BR2_PACKAGE_WPEFRAMEWORK_PROVISIONPROXY), y)
    NETFLIX52_CONF_OPTS += -DNETFLIX_USE_PROVISION=ON
    NETFLIX52_DEPENDENCIES += wpeframework
endif

ifneq ($(BR2_PACKAGE_NETFLIX52_KEYMAP),"")
NETFLIX52_CONF_OPTS += -DNETFLIX_USE_KEYMAP=$(call qstrip,$(BR2_PACKAGE_NETFLIX52_KEYMAP))
endif

NETFLIX52_CONF_OPTS += \
	-DCMAKE_C_FLAGS="$(CMAKE_C_FLAGS) $(TARGET_CFLAGS) $(NETFLIX52_FLAGS) -I$(STAGING_DIR)/usr/include" \
	-DCMAKE_CXX_FLAGS="$(CMAKE_CXX_FLAGS) $(TARGET_CXXFLAGS) $(NETFLIX52_FLAGS) -I$(STAGING_DIR)/usr/include" \
	-DCMAKE_EXE_LINKER_FLAGS="$(CMAKE_EXE_LINKER_FLAGS) -L$(STAGING_DIR)/usr/lib" \

define NETFLIX52_FIX_CONFIG_XMLS
	mkdir -p $(@D)/netflix/src/platform/gibbon/data/etc/conf
	cp -f $(@D)/netflix/resources/configuration/common.xml $(@D)/netflix/src/platform/gibbon/data/etc/conf/common.xml
	cp -f $(@D)/netflix/resources/configuration/config.xml $(@D)/netflix/src/platform/gibbon/data/etc/conf/config.xml
endef

NETFLIX52_POST_EXTRACT_HOOKS += NETFLIX52_FIX_CONFIG_XMLS

ifeq ($(BR2_PACKAGE_NETFLIX52_LIB),y)

ifeq ($(BR2_PACKAGE_WPEFRAMEWORK_COMPOSITORCLIENT),y)
define NETFLIX52_INSTALL_WPEFRAMEWORK_XML
	cp $(@D)/partner/gibbon/graphics/wpeframework/graphics.xml $(TARGET_DIR)/root/Netflix/etc/conf
endef
endif

define NETFLIX52_INSTALL_TO_STAGING
	make -C $(@D)/netflix preinstall
	$(INSTALL) -m 755 $(@D)/netflix/src/platform/gibbon/libnetflix.so $(1)/usr/lib
	$(INSTALL) -m 755 $(@D)/netflix/src/platform/gibbon/lib/libJavaScriptCore.so $(1)/usr/lib/
	$(INSTALL) -D package/netflix5/netflix.pc $(1)/usr/lib/pkgconfig/netflix.pc
	mkdir -p $(1)/usr/include/src/base
	mkdir -p $(1)/usr/include/3rdparty/JavaScriptCore/Source/WTF/wtf/nrdp
	mkdir -p $(1)/usr/include/3rdparty/lz4
	mkdir -p $(1)/usr/include/3rdparty/utf8
	mkdir -p $(1)/usr/include/src/nrd
	mkdir -p $(1)/usr/include/src/net
	mkdir -p $(1)/usr/include/netflix/src
	mkdir -p $(1)/usr/include/netflix/nrdbase
	mkdir -p $(1)/usr/include/netflix/nrd
	mkdir -p $(1)/usr/include/netflix/nrdnet
	mkdir -p $(1)/usr/include/netflix/gibbon
	#cp -Rpf $(@D)/release/include/* $(1)/usr/include/netflix/
	cp -Rpf $(@D)/netflix/src/base/*.h $(1)/usr/include/src/base/
	cp -Rpf $(@D)/netflix/src/nrd/* $(1)/usr/include/src/nrd
	cp -Rpf $(@D)/netflix/src/net/* $(1)/usr/include/src/net
	cp -Rpf $(@D)/netflix/3rdparty/adf/*.h $(1)/usr/include/netflix/
	cp -Rpf $(@D)/netflix/3rdparty/harfbuzz/src/*.h $(1)/usr/include/netflix/
	cp -Rpf $(@D)/netflix/3rdparty/utf8/*.h $(1)/usr/include/3rdparty/utf8/
	cp -Rpf $(@D)/netflix/3rdparty/lz4/lz4.h $(1)/usr/include/3rdparty/lz4/
	cp -Rpf $(@D)/netflix/3rdparty/JavaScriptCore/Source/WTF/wtf/nrdp/Pool.h $(1)/usr/include/3rdparty/JavaScriptCore/Source/WTF/wtf/nrdp/
	cp -Rpf $(@D)/netflix/3rdparty/JavaScriptCore/Source/WTF/wtf/nrdp/Maddy.h $(1)/usr/include/3rdparty/JavaScriptCore/Source/WTF/wtf/nrdp/
	cp -Rpf $(@D)/netflix/include/nrdbase/*.h $(1)/usr/include/netflix/nrdbase/
	cp -Rpf $(@D)/netflix/include/nrd/*.h $(1)/usr/include/netflix/nrd/
	cp -Rpf $(@D)/netflix/include/nrdnet/*.h $(1)/usr/include/netflix/nrdnet/
	cp -Rpf $(@D)/netflix/include/gibbon/*.h $(1)/usr/include/netflix/gibbon/
	cd $(@D)/netflix/src && find ./base/ -name "*.h" -exec cp --parents {} $(1)/usr/include/netflix/src \;
	cd $(@D)/netflix/src && find ./nrd/ -name "*.h" -exec cp --parents {} $(1)/usr/include/netflix/src \;
	cd $(@D)/netflix/src && find ./net/ -name "*.h" -exec cp --parents {} $(1)/usr/include/netflix/src \;
	cp -Rpf $(@D)/netflix/src/platform/gibbon/*.h $(1)/usr/include/netflix
	cp -Rpf $(@D)/netflix/src/platform/gibbon/bridge/*.h $(1)/usr/include/netflix
	cp -Rpf $(@D)/netflix/src/platform/gibbon/text/*.h $(1)/usr/include/netflix
	find $(1)/usr/include/netflix/nrdbase/ -name "*.h" -exec sed -i "s/^#include \"\.\.\/\.\.\//#include \"/g" {} \;
	find $(1)/usr/include/netflix/nrd/ -name "*.h" -exec sed -i "s/^#include \"\.\.\/\.\.\//#include \"/g" {} \;
	find $(1)/usr/include/netflix/nrdnet/ -name "*.h" -exec sed -i "s/^#include \"\.\.\/\.\.\//#include \"/g" {} \;

        mkdir -p $(1)/usr/include/netflix/3rdparty/utf8/
        cp -Rpf $(@D)/netflix/3rdparty/utf8/* $(1)/usr/include/netflix/3rdparty/utf8/
endef

define NETFLIX52_INSTALL_TO_TARGET
	$(INSTALL) -m 755 $(@D)/netflix/src/platform/gibbon/libnetflix.so $(1)/usr/lib
	$(INSTALL) -m 755 $(@D)/netflix/src/platform/gibbon/lib/libJavaScriptCore.so $(1)/usr/lib/
	$(STRIPCMD) $(1)/usr/lib/libnetflix.so

	mkdir -p $(1)/root/Netflix
	cp -r $(@D)/netflix/src/platform/gibbon/resources/gibbon/fonts $(1)/root/Netflix
	cp -r $(@D)/netflix/resources/etc $(1)/root/Netflix
	mkdir -p $(1)/root/Netflix/etc/conf
	cp -r $(@D)/netflix/src/platform/gibbon/resources/configuration/* $(1)/root/Netflix/etc/conf
	cp -r $(@D)/netflix/src/platform/gibbon/resources $(1)/root/Netflix
	cp -r $(@D)/netflix/resources/configuration/* $(1)/root/Netflix/etc/conf

        $(NETFLIX52_INSTALL_WPEFRAMEWORK_XML)
	cp $(@D)/netflix/src/platform/gibbon/resources/js/*.js $(1)/root/Netflix/resources/js
	cp $(@D)/netflix/src/platform/gibbon/resources/default/PartnerBridge.js $(1)/root/Netflix/resources/js
endef

else

define NETFLIX52_INSTALL_TARGET
	$(INSTALL) -m 755 $(@D)/netflix/src/platform/gibbon/netflix $(TARGET_DIR)/usr/bin
endef

endif

define NETFLIX52_INSTALL_STAGING_CMDS
	$(call NETFLIX52_INSTALL_TO_STAGING, ${STAGING_DIR})
endef

define NETFLIX52_INSTALL_TARGET_CMDS
	$(call NETFLIX52_INSTALL_TO_TARGET, ${TARGET_DIR})
endef

define NETFLIX52_PREPARE_DPI
	mkdir -p $(TARGET_DIR)/root/Netflix/dpi
	ln -sfn /etc/playready $(TARGET_DIR)/root/Netflix/dpi/playready
endef

NETFLIX52_POST_INSTALL_TARGET_HOOKS += NETFLIX52_PREPARE_DPI

ifeq ($(BR2_PACKAGE_NETFLIX52_CREATE_BINARY_ML_DELIVERY),y)
ML_DELIVERY_SIGNATURE=${NETFLIX52_VERSION}
ML_DELIVERY_PACKAGE=${NETFLIX52_NAME}
ML_DELIVERY_DIR=${STAGING_DIR}/${BINARY_ML_DELIVERY_PACKAGE}

define CREATE_BINARY_ML_DELIVERY
	mkdir -p ${ML_DELIVERY_DIR}/usr/lib/pkgconfig/
	mkdir -p ${ML_DELIVERY_DIR}/usr/include/
	$(call NETFLIX52_INSTALL_TO_STAGING, ${ML_DELIVERY_DIR})
	$(call NETFLIX52_INSTALL_TO_TARGET, ${ML_DELIVERY_DIR})
	mkdir -p ${ML_DELIVERY_DIR}/root/Netflix/dpi
	ln -sfn /etc/playready ${ML_DELIVERY_DIR}/root/Netflix/dpi/playready
	tar -cJf ${BINARIES_DIR}/${ML_DELIVERY_PACKAGE}-${ML_DELIVERY_SIGNATURE}.tar.xz -C ${STAGING_DIR} ${ML_DELIVERY_PACKAGE}
endef

NETFLIX52_POST_INSTALL_TARGET_HOOKS += CREATE_BINARY_ML_DELIVERY
endif

$(eval $(cmake-package))
