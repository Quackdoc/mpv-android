#!/bin/bash -e

. ../../include/path.sh
. ../../include/depinfo.sh

if [ "$1" == "build" ]; then
	true
elif [ "$1" == "clean" ]; then
	rm -rf _build$ndk_suffix
	exit 0
else
	exit 255
fi

# TODO figure this out
if [[ -z "$mpvarchoverride" && "$ndk_triple" != "arm"* ]]; then
	echo "Skipping build for $ndk_triple, only supposed to run on ARM (for now)"
	echo "To build anyway set DOIT=1 env variable"
	exit 0
fi
#

hostpy=python${v_python:0:3}
if ! command -v $hostpy; then
	echo "compatible Python ($hostpy) is required to build"
	exit 1
fi

# the NDK no longer ships binutils but python requires it...
export READELF=$(command -v readelf)
if ! command -v $READELF; then
	echo "binutils ($READELF) is required to build"
	exit 1
fi

function recompile_py () {
	find . -name '*.pyc' -delete
	$hostpy -OO -m compileall -b -j4 .
	# leave only the legacy locations (*.pyc next to *.py)
	find . -name "__pycache__" -print0 | xargs -0 -- rm -rf
}

function stub_ctypes () {
	rm -rf ctypes && mkdir -p ctypes
	cat >ctypes/__init__.py <<"FILE"
class cdll():
  @staticmethod
  def LoadLibrary(lib):
    raise OSError
FILE
}

export CFLAGS="-Os -I$prefix_dir/include"
export LDFLAGS="-L$prefix_dir/lib"

mkdir -p _build$ndk_suffix
cd _build$ndk_suffix

ac_cv_file__dev_ptmx=no ac_cv_file__dev_ptc=no \
../configure --host=$ndk_triple --build=${ndk_triple%%-*} \
	--enable-ipv6 --disable-shared --without-ensurepip
make -j$cores
rm -rf dest
make DESTDIR="$PWD/dest" install
inst=$PWD/dest/usr/local

out=$(realpath ../../../../app/src/main/assets/ytdl)
rm -f $out/python*
# copy & strip executable
cp -v python $out/python3
llvm-strip -s $out/python3
# clean stdlib to save space
pushd $inst/lib/python3.*
rm -r pydoc_data turtledemo # docs
rm -r test unittest/test # unittests
rm -r tkinter sqlite3 venv ensurepip # non-functional anyway
stub_ctypes # not compiled but needed by youtube-dl
rm -r lib2to3 idlelib distutils multiprocessing # not used by youtube-dl
# package stdlib into .zip file
recompile_py
zip -9 $out/python3${v_python:2:1}.zip -R '*.pyc'
popd
cd ..
