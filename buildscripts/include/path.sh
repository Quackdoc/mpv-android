#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd .. && pwd )"

os=linux
[[ "$OSTYPE" == "darwin"* ]] && os=mac
export os

if [ "$os" == "mac" ]; then
	[ -z "$cores" ] && cores=$(sysctl -n hw.ncpu)
	# various things rely on GNU behaviour
	export INSTALL=`which ginstall`
	export SED=gsed
else
	[ -z "$cores" ] && cores=$(grep -c ^processor /proc/cpuinfo)
fi
cores=${cores:-4}

# configure pkg-config paths if inside buildscripts
if [ -n "$ndk_triple" ]; then
	export PKG_CONFIG_SYSROOT_DIR="$prefix_dir"
	export PKG_CONFIG_LIBDIR="$PKG_CONFIG_SYSROOT_DIR/lib/pkgconfig"
	unset PKG_CONFIG_PATH
fi

if [ "$ISGIT" == "yes" ]; then 

SDK=/usr/local/lib/android/sdk
else
SDK=/opt/android-sdk
fi

NDK=$SDK/ndk/23.2.8568313
toolchain=$(echo "$NDK/toolchains/llvm/prebuilt/"*)
export PATH="$toolchain/bin:$NDK:$SDK/bin:$PATH"
