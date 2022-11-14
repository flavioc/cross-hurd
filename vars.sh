. ./config.sh

export AR=gar
export SCRIPT_DIR=$PWD
export SYSTEM=$PWD/tmp
export ROOT=/cross-tools
export SYS_ROOT=/tools
export TARGET=$CPU-pc-gnu
export HOST="$(echo $MACHTYPE | sed "s/$(echo $MACHTYPE | cut -d- -f2)/cross/g")"
export PATH=$ROOT/bin:$PATH
# You can change the GCC version here.
export CC="$HOST_MACHINE"-gcc
export CXX="$HOST_MACHINE"-g++

if [ ! -z "$CCACHE_DIRECTORY" ]; then
   export PATH=$CCACHE_DIRECTORY:$PATH
fi

# Package versions.
BINUTILS_VERSION=2.37
GCC_VERSION=11.2.0
FLEX_VERSION=2.6.4
ZLIB_VERSION=1.2.11
BASH_VERSION=5.1.16
COREUTILS_VERSION=8.32
# e2fsprogs 1.45.4 is failing due to something with sys/mount.h in configure
E2FSPROGS_VERSION=1.44.1
PKGCONFIGLITE_VERSION=0.28-1
LIBUUID_VERSION=1.0.3
UTIL_LINUX_VERSION=2.36
GRUB_VERSION=2.06
# Shadow 4.7 is failing due to sys/prctl.h missing
SHADOW_VERSION=4.6
SED_VERSION=4.7
GMP_VERSION=6.2.1
MPFR_VERSION=4.1.0
MPC_VERSION=1.2.0
NCURSES_VERSION=6.2
# 8.1: checking what tgetent() returns for an unknown terminal... configure: error: failed to compile test program.
VIM_BASE_VERSION=74
VIM_VERSION=7.4
GPG_ERROR_VERSION=1.38
GCRYPT_VERSION=1.8.7
MAKE_VERSION=4.3
GREP_VERSION=3.6
GAWK_VERSION=5.1.0
# Mach, Hurd and Glibc are all taken from the Git repository.

BINUTILS_SRC=binutils-"$BINUTILS_VERSION"
BINUTILS_PKG="${BINUTILS_SRC}.tar.bz2"
GCC_SRC=gcc-"$GCC_VERSION"
GCC_PKG="$GCC_SRC".tar.gz
GNUMACH_SRC=gnumach
GNUMIG_SRC=mig
HURD_SRC=hurd
GLIBC_SRC=glibc
GLIBC_TAG=master
FLEX_SRC=flex-"$FLEX_VERSION"
FLEX_PKG="$FLEX_SRC".tar.gz
ZLIB_SRC=zlib-"$ZLIB_VERSION"
ZLIB_PKG="$ZLIB_SRC".tar.gz
BASH_SRC=bash-"$BASH_VERSION"
BASH_PKG="$BASH_SRC".tar.gz
COREUTILS_SRC=coreutils-"$COREUTILS_VERSION"
COREUTILS_PKG="$COREUTILS_SRC".tar.xz
E2FSPROGS_SRC=e2fsprogs-"$E2FSPROGS_VERSION"
E2FSPROGS_PKG="$E2FSPROGS_SRC".tar.gz
PKGCONFIGLITE_SRC=pkg-config-lite-"$PKGCONFIGLITE_VERSION"
PKGCONFIGLITE_PKG="$PKGCONFIGLITE_SRC".tar.gz
LIBUUID_SRC=libuuid-"$LIBUUID_VERSION"
LIBUUID_PKG="$LIBUUID_SRC".tar.gz
UTIL_LINUX_SRC=util-linux-"$UTIL_LINUX_VERSION"
UTIL_LINUX_PKG="$UTIL_LINUX_SRC".tar.gz
GRUB_SRC=grub-"$GRUB_VERSION"
GRUB_PKG="$GRUB_SRC".tar.gz
SHADOW_SRC=shadow-"$SHADOW_VERSION"
SHADOW_PKG="$SHADOW_SRC".tar.xz
SED_SRC=sed-"$SED_VERSION"
SED_PKG="$SED_SRC".tar.xz
GMP_SRC=gmp-"$GMP_VERSION"
GMP_PKG="${GMP_SRC}".tar.bz2
MPFR_SRC=mpfr-"$MPFR_VERSION"
MPFR_PKG="${MPFR_SRC}".tar.bz2
MPC_SRC=mpc-"$MPC_VERSION"
MPC_PKG="${MPC_SRC}".tar.gz
NCURSES_SRC=ncurses-"$NCURSES_VERSION"
NCURSES_PKG="${NCURSES_SRC}".tar.gz
VIM_SRC=vim-"$VIM_VERSION"
VIM_PKG="$VIM_SRC".tar.bz2
GPG_ERROR_SRC=libgpg-error-"$GPG_ERROR_VERSION"
GPG_ERROR_PKG=${GPG_ERROR_SRC}.tar.bz2
GCRYPT_SRC=libgcrypt-"$GCRYPT_VERSION"
GCRYPT_PKG=${GCRYPT_SRC}.tar.bz2
MAKE_SRC=make-"$MAKE_VERSION"
MAKE_PKG=${MAKE_SRC}.tar.gz
GREP_SRC=grep-"$GREP_VERSION"
GREP_PKG=${GREP_SRC}.tar.xz
GAWK_SRC=gawk-"$GAWK_VERSION"
GAWK_PKG=${GAWK_SRC}.tar.xz

print_info ()
{
   echo "* $*"
}

