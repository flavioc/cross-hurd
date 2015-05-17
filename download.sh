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

download_gnumach () {
   if [ -d gnumach ]; then
      return 0
   fi
   git clone http://git.savannah.gnu.org/cgit/hurd/gnumach.git/
}

download_mig () {
   if [ -d mig ]; then
      return 0
   fi
   git clone http://git.savannah.gnu.org/cgit/hurd/mig.git/
}

download_hurd () {
   if [ -d hurd ]; then
      return 0
   fi
   git clone http://git.savannah.gnu.org/cgit/hurd/hurd.git/
}

apply_patch() {
   echo "* Using patch $1 (level: $2)"
   patch -p$2 < $1 || exit 1
}

download_glibc () {
   if [ -d glibc ]; then
      return 0
   fi
   git clone http://git.savannah.gnu.org/cgit/hurd/glibc.git/ &&
   cd glibc &&
   git pull origin tschwinge/Roger_Whittaker &&
   git clone http://git.savannah.gnu.org/cgit/hurd/libpthread.git/ &&
   cd libpthread &&
   (for p in $SCRIPT_DIR/patches/libpthread/*; do
      apply_patch $p 0
   done) &&
   cd .. &&
   (for p in $SCRIPT_DIR/patches/glibc/*; do
      apply_patch $p 1
   done) &&
   cd ..
}

mkdir -p $ROOT/src &&
cd $ROOT/src &&

download $BINUTILS_PKG $BINUTILS_URL &&
unpack jxf $BINUTILS_PKG $BINUTILS_SRC &&
download $GCC_PKG $GCC_URL &&
unpack jxf $GCC_PKG $GCC_SRC &&
download_gnumach &&
download_mig &&
download_hurd &&
download_glibc
