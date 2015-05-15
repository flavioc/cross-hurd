export ROOT=$PWD/tmp
export SYS_ROOT=$ROOT/sys
export TARGET=i386-pc-gnu
export HOST="$(echo $MACHTYPE | sed "s/$(echo $MACHTYPE | cut -d- -f2)/cross/g")"

# Package versions.
BINUTILS_SRC=binutils-2.25
BINUTILS_PKG="${BINUTILS_SRC}.tar.bz2"
GCC_SRC=gcc-4.9.2
GCC_PKG="$GCC_SRC".tar.bz2
