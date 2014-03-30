#!/bin/bash

XCODE_ROOT=`xcode-select -print-path`
ARCHS="i386 armv7 armv7s arm64"
SDK_VERSION="7.1"

STATIC_ARCHIVES=""
for ARCH in ${ARCHS}
do
    PLATFORM=""
    if [ "${ARCH}" == "i386" ]; then
        PLATFORM="iPhoneSimulator"
    else
        PLATFORM="iPhoneOS"
    fi

    export DEV_ROOT="${XCODE_ROOT}/Platforms/${PLATFORM}.platform/Developer"
    export SDK_ROOT="${DEV_ROOT}/SDKs/${PLATFORM}${SDK_VERSION}.sdk"
    export TOOLCHAIN_ROOT="${XCODE_ROOT}/Toolchains/XcodeDefault.xctoolchain/usr/bin/"
    export CC=clang
    export CXX=clang++
    export AR=${TOOLCHAIN_ROOT}libtool
    export RANLIB=${TOOLCHAIN_ROOT}ranlib
    export ARFLAGS="-static -o"
    export LDFLAGS="-arch ${ARCH} -isysroot ${SDK_ROOT}"
    export BUILD_PATH="BUILD_${ARCH}"
    export CXXFLAGS="-x c++ -arch ${ARCH} -isysroot ${SDK_ROOT} -I${BUILD_PATH}"
    mkdir -p ${BUILD_PATH}
   
    make -f Makefile

    mv *.o ${BUILD_PATH}
    mv *.d ${BUILD_PATH}
    mv libcryptopp.a ${BUILD_PATH}

    STATIC_ARCHIVES="${STATIC_ARCHIVES} ${BUILD_PATH}/libcryptopp.a"

done

echo "Creating universal library..."
mkdir -p bin
lipo -create ${STATIC_ARCHIVES} -output bin/libcryptopp.a
echo "Build done!"





