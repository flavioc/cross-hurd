#!/bin/sh

. ./vars.sh

BINUTILS_URL=http://ftp.gnu.org/gnu/binutils/$BINUTILS_PKG
GCC_URL=http://gcc.cybermirror.org/releases/gcc-4.9.2/"$GCC_PKG"

unpack () {
   if [ -d "$3" ]; then
      return 0
   fi
   echo "unpacking $2" &&
   tar $1 $2
}

download () {
   if [ -f $1 ]; then
      return 0
   fi
   wget $2
}

mkdir -p $ROOT/src &&
rm -f $ROOT/src/$BINUTILS_PKG &&
cd $ROOT/src &&

download $BINUTILS_PKG $BINUTILS_URL &&
unpack jxf $BINUTILS_PKG $BINUTILS_SRC &&
download $GCC_PKG $GCC_URL &&
unpack jxf $GCC_PKG $GCC_SRC
