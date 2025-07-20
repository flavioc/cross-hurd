#!/bin/sh

. ./vars.sh
. ./download-funcs.sh

mkdir -p $SOURCE &&
  pushd $SOURCE &&
  download_gcc &&
  download_package $MPFR_URL &&
  download_package $BINUTILS_URL &&
  download_package $BASH_URL &&
  download_package $FILE_URL &&
  download_package $INETUTILS_URL &&
  download $FLEX_PKG $FLEX_URL &&
  unpack zxf $FLEX_PKG $FLEX_SRC &&
  download $ZLIB_PKG $ZLIB_URL &&
  unpack zxf $ZLIB_PKG $ZLIB_SRC &&
  download $BZIP2_PKG $BZIP2_URL &&
  unpack zxf $BZIP2_PKG $BZIP2_SRC &&
  download_package $COREUTILS_URL &&
  download $E2FSPROGS_PKG $E2FSPROGS_URL &&
  unpack zxf $E2FSPROGS_PKG $E2FSPROGS_SRC &&
  download $PKGCONFIGLITE_PKG $PKGCONFIGLITE_URL &&
  unpack zxf $PKGCONFIGLITE_PKG $PKGCONFIGLITE_SRC &&
  download $LIBUUID_PKG $LIBUUID_URL &&
  unpack zxf $LIBUUID_PKG $LIBUUID_SRC &&
  download $UTIL_LINUX_PKG $UTIL_LINUX_URL &&
  unpack zxf $UTIL_LINUX_PKG $UTIL_LINUX_SRC &&
  download_package $GRUB_URL &&
  download_package $LIBXCRYPT_URL &&
  download $SHADOW_PKG $SHADOW_URL &&
  unpack Jxf $SHADOW_PKG $SHADOW_SRC &&
  download_gmp &&
  unpack jxf $GMP_PKG $GMP_SRC &&
  download $MPC_PKG $MPC_URL &&
  unpack zxf $MPC_PKG $MPC_SRC &&
  download_package $HTOP_URL &&
  download_package $NCURSES_URL &&
  download_libedit &&
  download_package $VIM_URL &&
  download_package $GPG_ERROR_URL &&
  download_package $GCRYPT_URL &&
  download_dmidecode &&
  download_findutils &&
  download_parted &&
  download_package $LIBDAEMON_URL &&
  download_libtirpc &&
  download_make &&
  download_grep &&
  download_package $GAWK_URL &&
  download_less &&
  download_sed &&
  download_dash &&
  download_ca_certificates &&
  download_iana_etc &&
  download_package $OPENSSL_URL &&
  download_wget &&
  download_perl &&
  download_package $LIBUNISTRING_URL &&
  download_package $LIBIDN2_URL &&
  download_package $LIBPSL_URL &&
  download_package $CURL_URL &&
  download_package $GIT_URL &&
  download_package $OPENSSH_URL &&
  download_libpciaccess &&
  download_gnumach &&
  download_mig &&
  download_dde &&
  download_netdde &&
  download_hurd &&
  download_glibc &&
  download_libacpica &&
  download_rumpkernel &&
  download_binutils_gdb &&
  echo "Download complete."
