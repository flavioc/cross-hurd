# Package versions.
FLEX_VERSION=2.6.4
ZLIB_VERSION=1.3.1
BZIP2_VERSION=1.0.8
# e2fsprogs 1.45.4 is failing due to something with sys/mount.h in configure
E2FSPROGS_VERSION=1.44.1
PKGCONFIGLITE_VERSION=0.28-1
LIBUUID_VERSION=1.0.3
UTIL_LINUX_MAJOR_VERSION=2.39
# 2.39.2 fails because libmount/src/hooks.c is being compiled without proper support.
UTIL_LINUX_VERSION=2.39
SHADOW_VERSION=4.14.2
SED_VERSION=4.9
MPC_VERSION=1.3.1
LIBEDIT_VERSION=20240517-3.1
MAKE_VERSION=4.4
GREP_VERSION=3.11
LESS_VERSION=661
DASH_VERSION=0.5.12
LIBPCIACCESS_VERSION=0.18.1
DMIDECODE_VERSION=3.5
IANA_ETC_VERSION=20240612
WGET_VERSION=1.24.5
PERL_CROSS_VERSION=1.5.3
PERL_VERSION=5.40.0
# Mach, Hurd and Glibc are all taken from the Git repository.

# coreutils
COREUTILS_VERSION=9.5
COREUTILS_SRC=coreutils-$COREUTILS_VERSION
COREUTILS_PKG=$COREUTILS_SRC.tar.xz
COREUTILS_URL=https://ftp.gnu.org/gnu/coreutils/$COREUTILS_PKG

# vim
VIM_VERSION=9.1.0041
VIM_SRC=vim-"$VIM_VERSION"
VIM_PKG=$VIM_SRC.tar.gz
VIM_URL=https://github.com/vim/vim/archive/v$VIM_VERSION/$VIM_PKG

# libunistring
LIBUNISTRING_VERSION=1.1
LIBUNISTRING_SRC=libunistring-$LIBUNISTRING_VERSION
LIBUNISTRING_PKG=$LIBUNISTRING_SRC.tar.xz
LIBUNISTRING_URL=https://ftp.gnu.org/gnu/libunistring/$LIBUNISTRING_PKG

# libidn2
LIBIDN2_VERSION=2.3.7
LIBIDN2_SRC=libidn2-$LIBIDN2_VERSION
LIBIDN2_PKG=$LIBIDN2_SRC.tar.gz
LIBIDN2_URL=https://ftp.gnu.org/gnu/libidn/$LIBIDN2_PKG

# libpsl
LIBPSL_VERSION=0.21.5
LIBPSL_SRC=libpsl-$LIBPSL_VERSION
LIBPSL_PKG=$LIBPSL_SRC.tar.gz
LIBPSL_URL=https://github.com/rockdaboot/libpsl/releases/download/$LIBPSL_VERSION/$LIBPSL_PKG

# curl
CURL_VERSION=8.8.0
CURL_SRC=curl-$CURL_VERSION
CURL_PKG=$CURL_SRC.tar.xz
CURL_URL=https://curl.se/download/$CURL_PKG

# libdaemon
LIBDAEMON_VERSION=0.14
LIBDAEMON_SRC=libdaemon-$LIBDAEMON_VERSION
LIBDAEMON_PKG=$LIBDAEMON_SRC.tar.gz
LIBDAEMON_URL=https://0pointer.de/lennart/projects/libdaemon/$LIBDAEMON_PKG

# ca-certificates
CA_CERTIFICATES_URL=https://salsa.debian.org/debian/ca-certificates.git
CA_CERTIFICATES_SRC=ca-certificates

# git
GIT_VERSION=2.50.1
GIT_SRC=git-$GIT_VERSION
GIT_PKG=$GIT_SRC.tar.xz
GIT_URL=https://www.kernel.org/pub/software/scm/git/$GIT_PKG

# openssl
OPENSSL_VERSION=3.3.1
OPENSSL_SRC=openssl-$OPENSSL_VERSION
OPENSSL_PKG=$OPENSSL_SRC.tar.gz
OPENSSL_URL=https://www.openssl.org/source/$OPENSSL_PKG

# libgpg-error
GPG_ERROR_VERSION=1.55
GPG_ERROR_SRC=libgpg-error-$GPG_ERROR_VERSION
GPG_ERROR_PKG=$GPG_ERROR_SRC.tar.bz2
GPG_ERROR_URL=https://gnupg.org/ftp/gcrypt/libgpg-error/$GPG_ERROR_PKG

# libgcrypt
GCRYPT_VERSION=1.11.1
GCRYPT_SRC=libgcrypt-$GCRYPT_VERSION
GCRYPT_PKG=$GCRYPT_SRC.tar.bz2
GCRYPT_URL=https://gnupg.org/ftp/gcrypt/libgcrypt/$GCRYPT_PKG

# binutils
BINUTILS_VERSION=2.44
BINUTILS_SRC=binutils-$BINUTILS_VERSION
BINUTILS_PKG=$BINUTILS_SRC.tar.bz2
BINUTILS_URL=https://ftp.gnu.org/gnu/binutils/$BINUTILS_PKG

# GCC
GCC_VERSION=15.1.0
GCC_SRC=gcc-$GCC_VERSION
GCC_PKG=$GCC_SRC.tar.xz
GCC_URL=https://ftp.gnu.org/gnu/gcc/gcc-$GCC_VERSION/$GCC_PKG

# parted
PARTED_VERSION=3.6
PARTED_SRC=parted-$PARTED_VERSION
PARTED_PKG=$PARTED_SRC.tar.xz
PARTED_URL=https://ftp.gnu.org/gnu/parted/$PARTED_PKG

# libtirpc
LIBTIRPC_VERSION=1.3.6
LIBTIRPC_SRC=libtirpc-$LIBTIRPC_VERSION
LIBTIRPC_PKG=$LIBTIRPC_SRC.tar.bz2
LIBTIRPC_URL=https://sourceforge.net/projects/libtirpc/files/libtirpc/$LIBTIRPC_VERSION/$LIBTIRPC_PKG

# openssh
OPENSSH_VERSION=9.8p1
OPENSSH_SRC=openssh-$OPENSSH_VERSION
OPENSSH_PKG=$OPENSSH_SRC.tar.gz
OPENSSH_URL=https://cdn.openbsd.org/pub/OpenBSD/OpenSSH/portable/$OPENSSH_PKG

# gawk
GAWK_VERSION=5.3.2
GAWK_SRC=gawk-$GAWK_VERSION
GAWK_PKG=$GAWK_SRC.tar.xz
GAWK_URL=https://ftp.gnu.org/gnu/gawk/$GAWK_PKG

# grub
GRUB_VERSION=2.06
GRUB_SRC=grub-$GRUB_VERSION
GRUB_PKG=$GRUB_SRC.tar.gz
GRUB_URL=https://ftp.gnu.org/gnu/grub/$GRUB_PKG

# htop
HTOP_VERSION=3.3.0
HTOP_SRC=htop-$HTOP_VERSION
HTOP_PKG=$HTOP_SRC.tar.xz
HTOP_URL=https://github.com/htop-dev/htop/releases/download/$HTOP_VERSION/$HTOP_PKG

# bash
BASH_VERSION=5.3
BASH_SRC=bash-$BASH_VERSION
BASH_PKG=$BASH_SRC.tar.gz
BASH_URL=https://ftp.gnu.org/gnu/bash/"$BASH_PKG"

# ncurses
NCURSES_VERSION=6.4
NCURSES_SRC=ncurses-${NCURSES_VERSION}
NCURSES_PKG=${NCURSES_SRC}.tar.gz
NCURSES_URL=https://ftp.gnu.org/gnu/ncurses/$NCURSES_PKG

# file
FILE_VERSION=5.45
FILE_SRC=file-$FILE_VERSION
FILE_PKG=$FILE_SRC.tar.gz
FILE_URL=http://ftp.astron.com/pub/file/$FILE_PKG

# gdb
GDB_SRC=binutils-gdb

# mpfr
MPFR_VERSION=4.2.2
MPFR_SRC=mpfr-$MPFR_VERSION
MPFR_PKG=$MPFR_SRC.tar.bz2
MPFR_URL=http://mpfr.org/mpfr-current/$MPFR_PKG

# libxcrypt
LIBXCRYPT_VERSION=4.4.38
LIBXCRYPT_SRC=libxcrypt-$LIBXCRYPT_VERSION
LIBXCRYPT_PKG=$LIBXCRYPT_SRC.tar.xz
LIBXCRYPT_URL=https://github.com/besser82/libxcrypt/releases/download/v$LIBXCRYPT_VERSION/$LIBXCRYPT_PKG

# gmp
GMP_VERSION=6.3.0
GMP_SRC=gmp-"$GMP_VERSION"
GMP_PKG="${GMP_SRC}".tar.bz2
GMP_URL=https://ftp.gnu.org/gnu/gmp/"$GMP_PKG"

# inetutils
INETUTILS_VERSION=2.6
INETUTILS_SRC=inetutils-$INETUTILS_VERSION
INETUTILS_PKG=$INETUTILS_SRC.tar.xz
INETUTILS_URL=https://ftp.gnu.org/gnu/inetutils/$INETUTILS_PKG

# findutils
FINDUTILS_VERSION=4.10.0
FINDUTILS_SRC=findutils-$FINDUTILS_VERSION
FINDUTILS_PKG=$FINDUTILS_SRC.tar.xz
FINDUTILS_URL=https://ftp.gnu.org/gnu/findutils/$FINDUTILS_PKG
