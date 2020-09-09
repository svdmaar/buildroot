#!/bin/sh

export SOURCE=/media/ml
#export LD_LIBRARY_PATH=$SOURCE/usr/lib:/lib:/usr/lib:$SOURCE/lib
export LD_LIBRARY_PATH=$SOURCE/usr/lib:/lib:/usr/lib:$SOURCE/lib:$SOURCE/usr/lib/wpeframework/plugins:$SOURCE/usr/lib/wpeframework/proxystubs
export PATH=$SOURCE/usr/bin:$PATH
export GST_PLUGIN_SCANNER=$SOURCE/usr/libexec/gstreamer-1.0/gst-plugin-scanner
export GST_PLUGIN_SYSTEM_PATH=$SOURCE/usr/lib/gstreamer-1.0

export XKB_CONFIG_ROOT=$SOURCE/usr/share/X11/xkb

# By default nxserver starts with 1080p, launch webkit with same resolution
export WPE_NEXUS_FORMAT="1080p60Hz"

export DESTINATION=/media/vftv
	
# Currently the root system is read-only. Since we cannot add anything there we bind 
# existing directories with a copy of the actual system. All the stuff we want to 
# add is symbolicly linked in from our sources..
if [ ! -d $DESTINATION ]; then

	mkdir -p $DESTINATION/share
	mkdir -p $DESTINATION/etc
	mkdir -p $DESTINATION/lib
	mkdir -p $DESTINATION/usr/bin
	cp -rfap /usr/share/* $DESTINATION/share
	cp -rfap /etc/* $DESTINATION/etc
	cp -rfap /usr/lib/* $DESTINATION/lib
	cp -rfap /usr/bin/* $DESTINATION/usr/bin

	ln -s $SOURCE/usr/share/mime $DESTINATION/share/mime
	ln -s $SOURCE/usr/share/X11 $DESTINATION/share/X11
	ln -s $SOURCE/usr/share/WPEFramework $DESTINATION/share/WPEFramework
	ln -s $SOURCE/usr/share/fonts $DESTINATION/share/fonts
	ln -s $SOURCE/etc/ssl/certs/ca-certificates.crt $DESTINATION/etc/ssl/certs/ca-certificates.crt
	ln -s $SOURCE/etc/ssl $DESTINATION/lib/ssl
	ln -s $SOURCE/etc/fonts $DESTINATION/etc/fonts
	ln -s $SOURCE/etc/WPEFramework $DESTINATION/etc/WPEFramework
	ln -s $SOURCE/usr/lib/gio $DESTINATION/lib/gio
	ln -s $SOURCE/usr/bin/WPENetworkProcess $DESTINATION/usr/bin/WPENetworkProcess
	ln -s $SOURCE/usr/bin/WPEWebProcess $DESTINATION/usr/bin/WPEWebProcess
	ln -s $SOURCE/usr/bin/WPEStorageProcess $DESTINATION/usr/bin/WPEStorageProcess
fi

grep -q "/usr/share ext4" /proc/mounts && echo "/usr/share is already mounted" || mount -t ext4 --bind $DESTINATION/share /usr/share
grep -q "/etc ext4" /proc/mounts && echo "/etc is already mounted" || mount -t ext4 --bind $DESTINATION/etc /etc
grep -q "/usr/lib ext4" /proc/mounts && echo "/usr/lib is already mounted" || mount -t ext4 --bind $DESTINATION/lib /usr/lib
grep -q "/usr/bin ext4" /proc/mounts && echo "/usr/bin is already mounted" || mount -t ext4 --bind $DESTINATION/usr/bin/ /usr/bin

#LD_PRELOAD=$SOURCE/usr/lib/libstdc\+\+.so.6.0.21 WPEFramework
WPEFramework
