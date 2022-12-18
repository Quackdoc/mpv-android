FROM fedora:latest as build

RUN dnf -y update && \
    dnf -y groupinstall "Development Tools" && \
    dnf -y install \
    	which python3-mako nasm \
        autoconf \
        pkgconfig \
        libtool \
        ninja-build \
        python3-pip \
		python3-setuptools \
		unzip \
		wget \
        java-11-openjdk-devel   \
        zlib.i686               \
        ncurses-libs.i686       \
        bzip2-libs.i686       && \
        pip3 install meson

RUN cd /tmp && \
    wget https://dl.google.com/android/repository/commandlinetools-linux-8512546_latest.zip && \
    unzip commandlinetools-linux-8512546_latest.zip && \
    mkdir -p /opt/android-sdk/cmdline-tools && mv cmdline-tools /opt/android-sdk/cmdline-tools/latest


RUN export JAVA_HOME=$(readlink -f /usr/bin/java | sed "s:bin/java::") && \
     cd /opt/android-sdk/cmdline-tools/latest/bin && yes | ./sdkmanager --licenses && \
     ./sdkmanager "ndk;23.2.8568313" && \
     cp -n /opt/android-sdk/ndk/23.2.8568313/sources/third_party/vulkan/src/include/vulkan/* \
     /opt/android-sdk/ndk/23.2.8568313/toolchains/llvm/prebuilt/linux-x86_64/sysroot/usr/include/vulkan/

RUN mkdir /build 
    # && cd /build && git clone https://github.com/Quackdoc/mpv-android.git && cd mpv-android && \
    #export JAVA_HOME=$(readlink -f /usr/bin/java | sed "s:bin/java::") && \
    #export ANDROID_SDK_ROOT=/opt/android-sdk&& \
    #chmod +x gradlew && cd buildscripts && chmod +x github-prepare.sh && ./github-prepare.sh && ./buildall.sh -n


WORKDIR /build
