#!/bin/sh

. ./vars.sh
. ./download-funcs.sh

mkdir -p $SYSTEM/src &&
cd $SYSTEM/src &&

download_gcc &&
download_binutils &&
download_gnumach &&
download_mig &&
download_hurd &&
download_glibc &&
download $FLEX_PKG $FLEX_URL &&
unpack zxf $FLEX_PKG $FLEX_SRC &&
download $ZLIB_PKG $ZLIB_URL &&
unpack zxf $ZLIB_PKG $ZLIB_SRC &&
download $BASH_PKG $BASH_URL &&
unpack zxf $BASH_PKG $BASH_SRC &&
download_coreutils &&
download $E2FSPROGS_PKG $E2FSPROGS_URL &&
unpack zxf $E2FSPROGS_PKG $E2FSPROGS_SRC &&
download $PKGCONFIGLITE_PKG $PKGCONFIGLITE_URL &&
unpack zxf $PKGCONFIGLITE_PKG $PKGCONFIGLITE_SRC &&
download $LIBUUID_PKG $LIBUUID_URL &&
unpack zxf $LIBUUID_PKG $LIBUUID_SRC &&
download $UTIL_LINUX_PKG $UTIL_LINUX_URL &&
unpack zxf $UTIL_LINUX_PKG $UTIL_LINUX_SRC &&

download $GRUB_PKG $GRUB_URL &&
unpack zxf $GRUB_PKG $GRUB_SRC &&

download $SHADOW_PKG $SHADOW_URL &&
unpack Jxf $SHADOW_PKG $SHADOW_SRC &&

download $GMP_PKG $GMP_URL &&
unpack jxf $GMP_PKG $GMP_SRC &&

download $MPFR_PKG $MPFR_URL &&
unpack jxf $MPFR_PKG $MPFR_SRC &&

download $MPC_PKG $MPC_URL &&
unpack zxf $MPC_PKG $MPC_SRC &&

download_ncurses &&

download_vim &&

download_sed 
