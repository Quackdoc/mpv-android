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

git submodule update --init --recursive --depth 1 --recommend-shallow third_party/highway third_party/skcms third_party/brotli

cmake  -B $build \
    -GNinja \
    -DCMAKE_TOOLCHAIN_FILE="$ANDROID_NDK_HOME"/build/cmake/android.toolchain.cmake \
    -DANDROID_PLATFORM=21 \
    -DANDROID_ABI=$cpu \
    -DANDROID_ALLOW_UNDEFINED_SYMBOLS=FALSE \
    -DANDROID_NO_UNDEFINED=ON \
    -DBUILD_SHARED_LIBS:BOOL=OFF \
    -DJPEGXL_STATIC:BOOL=OFF \
    -DJPEGXL_EMSCRIPTEN:BOOL=OFF \
    -DCMAKE_BUILD_TYPE:STRING='Release' \
    -DJPEGXL_ENABLE_BENCHMARK:BOOL=OFF \
    -DJPEGXL_ENABLE_EXAMPLES:BOOL=OFF \
    -DJPEGXL_ENABLE_FUZZERS:BOOL=OFF \
    -DJPEGXL_ENABLE_PLUGINS:BOOL=OFF \
    -DJPEGXL_ENABLE_VIEWERS:BOOL=OFF \
    -DJPEGXL_FORCE_SYSTEM_BROTLI:BOOL=ON \
    -DJPEGXL_BUNDLE_LIBPNG:BOOL=OFF \
    -DJPEGXL_ENABLE_TOOLS:BOOL=OFF \
    -DJPEGXL_ENABLE_JNI:BOOL=OFF \
    -DJPEGXL_ENABLE_JPEGLI:BOOL=OFF \
    -DJPEGXL_ENABLE_DOXYGEN:BOOL=OFF \
    -DJPEGXL_ENABLE_MANPAGES:BOOL=OFF \
    -DJPEGXL_ENABLE_SJPEG:BOOL=OFF \
    -DJPEGXL_ENABLE_TRANSCODE_JPEG:BOOL=OFF \
    -DBUILD_TESTING:BOOL=OFF \
    -DCMAKE_PREFIX_PATH="$prefix_dir"/lib \
    -DCMAKE_MODULE_PATH="$prefix_dir"/lib \
    -DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY=BOTH \
    -DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE=BOTH \
    -DCMAKE_FIND_ROOT_PATH_MODE_PACKAGE=BOTH \
    -Wno-dev



cmake --build $build
DESTDIR="$prefix_dir" cmake --install $build

echo "Cflags.private: -DJXL_STATIC_DEFINE=1" >> "$prefix_dir"/lib/pkgconfig/libjxl.pc
echo "Libs.private: -lm -lc++ -lstdc++" >> "$prefix_dir"/lib/pkgconfig/libjxl.pc

echo "Cflags.private: -DJXL_STATIC_DEFINE=1" >> "$prefix_dir"/lib/pkgconfig/libjxl_threads.pc
echo "Libs.private: -lm -lc++ -lstdc++" >> "$prefix_dir"/lib/pkgconfig/libjxl_threads.pc
