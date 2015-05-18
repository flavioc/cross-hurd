#!/bin/sh

. ./vars.sh

BINUTILS_URL=http://ftp.gnu.org/gnu/binutils/$BINUTILS_PKG
GCC_URL=http://gcc.cybermirror.org/releases/gcc-4.9.2/"$GCC_PKG"
FLEX_URL=http://downloads.sourceforge.net/project/flex/"$FLEX_PKG"
ZLIB_URL=http://zlib.net/"$ZLIB_PKG"
BASH_URL=https://ftp.gnu.org/gnu/bash/"$BASH_PKG"
COREUTILS_URL=http://ftp.gnu.org/gnu/coreutils/"$COREUTILS_PKG"
E2FSPROGS_URL=https://www.kernel.org/pub/linux/kernel/people/tytso/e2fsprogs/v1.42.12/"$E2FSPROGS_PKG"
PKGCONFIGLITE_URL=http://downloads.sourceforge.net/project/pkgconfiglite/0.28-1/"$PKGCONFIGLITE_PKG"

unpack () {
   if [ -d "$3" ]; then
      return 0
   fi
   print_info "unpacking $2" &&
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
   git clone http://git.savannah.gnu.org/cgit/hurd/hurd.git/ &&
   cd hurd && apply_patch $SCRIPT_DIR/patches/hurd/hurd-cross.patch 1 &&
   cd ..
}

apply_patch() {
   print_info "Using patch $1 (level: $2)"
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

download_gcc () {
   download $GCC_PKG $GCC_URL &&
   if [ -d "$GCC_SRC" ]; then
      return 0
   fi
   unpack jxf $GCC_PKG $GCC_SRC &&
   cd $GCC_SRC &&
   pwd &&
   apply_patch $SCRIPT_DIR/patches/gcc/specs.patch 1 &&
   cd ..
}

download_coreutils () {
   download $COREUTILS_PKG $COREUTILS_URL &&
   if [ ! -d "$COREUTILS_SRC" ]; then
	   unpack Jxf $COREUTILS_PKG $COREUTILS_SRC &&
		cd $COREUTILS_SRC &&
	   apply_patch $SCRIPT_DIR/patches/coreutils/*.patch 1 &&
	cd ..
   fi
}

mkdir -p $SYSTEM/src &&
cd $SYSTEM/src &&

download_gcc &&
download $BINUTILS_PKG $BINUTILS_URL &&
unpack jxf $BINUTILS_PKG $BINUTILS_SRC &&
download_gnumach &&
download_mig &&
download_hurd &&
download_glibc &&
download $FLEX_PKG $FLEX_URL &&
unpack jxf $FLEX_PKG $FLEX_SRC &&
download $ZLIB_PKG $ZLIB_URL &&
unpack zxf $ZLIB_PKG $ZLIB_SRC &&
download $BASH_PKG $BASH_URL &&
unpack zxf $BASH_PKG $BASH_SRC &&
download_coreutils &&
download $E2FSPROGS_PKG $E2FSPROGS_URL &&
unpack zxf $E2FSPROGS_PKG $E2FSPROGS_SRC
download $PKGCONFIGLITE_PKG $PKGCONFIGLITE_URL &&
unpack zxf $PKGCONFIGLITE_PKG $PKGCONFIGLITE_SRC
