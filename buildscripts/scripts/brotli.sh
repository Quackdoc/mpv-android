. ../../include/path.sh
build=_build$ndk_suffix

if [ "$1" == "build" ]; then
	true
elif [ "$1" == "clean" ]; then
	rm -rf $build
	exit 0
else
	exit 255
fi

cpu=armeabi-v7a
[[ "$ndk_triple" == "aarch64"* ]] && cpu=arm64-v8a
[[ "$ndk_triple" == "x86_64"* ]] && cpu=x86_64
[[ "$ndk_triple" == "i686"* ]] && cpu=x86

cmake -B $build \
    -GNinja \
    -DCMAKE_TOOLCHAIN_FILE="$ANDROID_NDK_HOME"/build/cmake/android.toolchain.cmake \
    -DANDROID_PLATFORM=21 \
    -DANDROID_ABI=$cpu \
    -DCMAKE_BUILD_TYPE:STRING='Release' \
    -DBUILD_SHARED_LIBS=OFF \
    -DCMAKE_PREFIX_PATH="$prefix_dir"/lib \
    -DANDROID_NO_UNDEFINED=ON \
    -DCMAKE_POSITION_INDEPENDENT_CODE=ON 

ninja -C $build -j$cores
DESTDIR="$prefix_dir" ninja -C $build install
