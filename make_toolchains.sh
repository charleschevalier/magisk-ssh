#!/usr/bin/env sh

if [ "$#" -ne 1 ] || ! [ -d "$1" ]; then
  echo "Usage: $0 NDK_DIRECTORY" >&2
  echo "Note that only NDK <= 17 is supported to include gcc"
  echo "Use NDK 14 if you want no trouble during build."
  exit 1
fi

ANDROID_NDK_ROOT=$1

mkdir -p $ANDROID_NDK_ROOT/custom-toolchains
$ANDROID_NDK_ROOT/build/tools/make_standalone_toolchain.py --arch arm --api 23 --install-dir $ANDROID_NDK_ROOT/custom-toolchains/arm
$ANDROID_NDK_ROOT/build/tools/make_standalone_toolchain.py --arch arm64 --api 23 --install-dir $ANDROID_NDK_ROOT/custom-toolchains/arm64
$ANDROID_NDK_ROOT/build/tools/make_standalone_toolchain.py --arch x86 --api 23 --install-dir $ANDROID_NDK_ROOT/custom-toolchains/x86
$ANDROID_NDK_ROOT/build/tools/make_standalone_toolchain.py --arch x86_64 --api 23 --install-dir $ANDROID_NDK_ROOT/custom-toolchains/x86_64