#!/bin/sh

. ./vars.sh
export CC="${ROOT}/bin/${TARGET}-gcc"
export CXX="${ROOT}/bin/${TARGET}-g++"
export AR="${ROOT}/bin/${TARGET}-ar"
export AS="${ROOT}/bin/${TARGET}-as"
export RANLIB="${ROOT}/bin/${TARGET}-ranlib"
export LD="${ROOT}/bin/${TARGET}-ld"
export STRIP="${ROOT}/${TARGET}-strip"
export MIG="${ROOT}/bin/${TARGET}-mig"

install_flex() {
	cd "$FLEX_SRC" &&
	ac_cv_func_realloc_0_nonnull=yes ac_cv_func_malloc_0_nonnull=yes \
	./configure --prefix="$SYS_ROOT" \
		--build="$HOST" \
		--host="$TARGET" &&
	make all install &&
	cd ..
}

install_mig() {
   cd "$GNUMIG_SRC" &&
   autoreconf -i &&
   cd .. &&
   mkdir -p "$GNUMIG_SRC".obj &&
   cd "$GNUMIG_SRC".obj &&
   rm -f config.cache &&
   ../$GNUMIG_SRC/configure \
      --build="$HOST" \
      --host="$TARGET" \
      --prefix=/sys \
      --target="$TARGET" &&
   make clean &&
   make -j$PROCS DESTDIR="$ROOT" all install &&
   cd ..
}

install_zlib() {
   cd "$ZLIB_SRC" &&
./configure --prefix=$SYS_ROOT &&
make &&
make install &&
cd ..
}

install_gnumach() {
   cd "$GNUMACH_SRC" &&
   autoreconf -i &&
   cd .. &&
   rm -rf "$GNUMACH_SRC".obj &&
   mkdir -p "$GNUMACH_SRC".obj &&
   cd "$GNUMACH_SRC".obj &&
   ../$GNUMACH_SRC/configure \
	   --host="$TARGET" \
	   --build="$HOST" \
	   --exec-prefix= \
	   --enable-kdb \
	   --enable-kmsg \
	   --enable-pae \
	   --prefix= &&
   make -j$PROCS DESTDIR="$ROOT" gnumach.gz gnumach gnumach.msgids install &&
   mkdir -p $ROOT/boot &&
   cp gnumach.gz $ROOT/boot/ &&
   cd -
}

install_hurd() {
   cd "$HURD_SRC" &&
   autoreconf -i &&
   cd .. &&
   #rm -rf "$HURD_SRC".obj &&
   mkdir -p "$HURD_SRC".obj &&
   cd "$HURD_SRC".obj &&
   rm -f config.cache cnfig.status &&
   ../$HURD_SRC/configure \
      --build="$HOST" \
      --host="$TARGET" \
      --prefix= \
      --without-parted \
      --disable-profile &&
   make -j$PROCS prefix="$SYS_ROOT" all install &&
   cd ..
}

cd "$ROOT"/src &&
install_zlib &&
#install_flex &&
#install_mig &&
#install_gnumach
install_hurd
