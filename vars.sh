export PROCS=2
export SCRIPT_DIR=$PWD
export ROOT=$PWD/tmp
export SYS_ROOT=$ROOT/sys
export TARGET=i586-pc-gnu
export HOST="$(echo $MACHTYPE | sed "s/$(echo $MACHTYPE | cut -d- -f2)/cross/g")"

# Package versions.
BINUTILS_VERSION=2.25
GCC_VERSION=4.9.2

BINUTILS_SRC=binutils-"$BINUTILS_VERSION"
BINUTILS_PKG="${BINUTILS_SRC}.tar.bz2"
GCC_SRC=gcc-"$GCC_VERSION"
GCC_PKG="$GCC_SRC".tar.bz2
GNUMACH_SRC=gnumach
GNUMIG_SRC=mig
HURD_SRC=hurd
GLIBC_SRC=glibc
