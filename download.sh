#!/bin/sh

. ./vars.sh
. ./download-funcs.sh

mkdir -p $SOURCE &&
cd $SOURCE &&

download_gcc &&
download_binutils &&
download $FLEX_PKG $FLEX_URL &&
unpack zxf $FLEX_PKG $FLEX_SRC &&
download $ZLIB_PKG $ZLIB_URL &&
unpack zxf $ZLIB_PKG $ZLIB_SRC &&
download $BZIP2_PKG $BZIP2_URL &&
unpack zxf $BZIP2_PKG $BZIP2_SRC &&
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

download_grub &&

download $SHADOW_PKG $SHADOW_URL &&
unpack Jxf $SHADOW_PKG $SHADOW_SRC &&

download $GMP_PKG $GMP_URL &&
unpack jxf $GMP_PKG $GMP_SRC &&

download $MPFR_PKG $MPFR_URL &&
unpack jxf $MPFR_PKG $MPFR_SRC &&

download $MPC_PKG $MPC_URL &&
unpack zxf $MPC_PKG $MPC_SRC &&

download_libxcrypt &&

download_ncurses &&

download_vim &&

download_gpg_error &&
download_gcrypt &&

download_make &&
download_grep &&
download_gawk &&

download_sed &&
download_dash &&
download_libpciaccess &&
download_gnumach &&
download_mig &&
download_hurd &&
download_glibc &&
download_libacpica &&
download_rumpkernel &&
echo "Download complete."
