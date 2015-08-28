#!/bin/sh

. ./vars.sh
. ./download-funcs.sh

compile_binutils ()
{
   print_info "Cross compiling binutils"
   rm -rf "$BINUTILS_SRC".obj &&
      mkdir -p "$BINUTILS_SRC".obj &&
      cd "$BINUTILS_SRC".obj &&
      AR=ar AS=as ../$BINUTILS_SRC/configure \
      --host="$HOST" \
      --target="$TARGET" \
      --prefix="$ROOT" \
      --with-sysroot="$SYSTEM" \
      --disable-static \
      --with-lib-path="$SYS_ROOT"/lib \
      --disable-multilib \
      --disable-werror \
      --disable-nls &&
      make -j$PROCS all install &&
      cd ..
}

compile_gcc ()
{
   print_info "Cross compiling first phase of GCC"
   if [ -d "$GCC_SRC" ]; then
      rm -rf "$GCC_SRC"
   fi
   unpack_gcc
   rm -rf "$GCC_SRC".obj &&
      mkdir -p "$GCC_SRC".obj &&
      cd "$GCC_SRC".obj &&
      AR=ar LDFLAGS="-Wl,-rpath,${ROOT}/lib" \
      ../$GCC_SRC/configure \
      --prefix="$ROOT" \
      --build="$HOST" \
      --host="$HOST" \
      --target="$TARGET" \
      --with-sysroot="$SYSTEM" \
      --with-local-prefix="$SYS_ROOT" \
      --with-native-system-header-dir="$SYS_ROOT"/include \
      --disable-nls \
      --disable-shared \
      --disable-threads \
      --disable-multilib \
      --disable-target-zlib \
      --with-system-zlib \
      --without-headers \
      --with-newlib \
      --enable-languages=c &&
      make -j$PROCS all-gcc install-gcc &&
      make -j$PROCS configure-target-libgcc &&
      cd "$TARGET"/libgcc &&
      make -j$PROCS 'libgcc-objects = $(lib2funcs-o) $(lib2-divmod-o)' all install &&
      cd - &&
      mv config.status config.status.removed &&
      rm -f config.cache *config.cache */*/config.cache &&
      cd ..
}

install_gnumach_headers() {
   print_info "Installing GNU Mach Headers" &&
      cd "$GNUMACH_SRC" &&
      autoreconf -i &&
      cd .. &&
      mkdir -p "$GNUMACH_SRC".obj &&
      cd "$GNUMACH_SRC".obj &&
      ../$GNUMACH_SRC/configure \
      --host="$TARGET" \
      --prefix="$SYS_ROOT" &&
      make -j$PROCS install-data &&
      cd -
}

install_gnumig() {
   print_info "Installing cross GNU Mig" &&
      cd "$GNUMIG_SRC" &&
      autoreconf -i &&
      cd .. &&
      mkdir -p "$GNUMIG_SRC".obj &&
      cd "$GNUMIG_SRC".obj &&
      ../$GNUMIG_SRC/configure --target="$TARGET" \
      --prefix="$ROOT" &&
      make -j$PROCS all install &&
      cd ..
}

install_hurd_headers() {
   print_info "Installing Hurd headers" &&
      cd "$HURD_SRC" &&
      autoreconf -i &&
      cd .. &&
      mkdir -p "$HURD_SRC".obj &&
      cd "$HURD_SRC".obj &&
      ../$HURD_SRC/configure \
      --host="$TARGET" \
      --prefix= \
      --disable-profile \
      --without-parted &&
      make -j$PROCS prefix="$SYS_ROOT" no_deps=t install-headers &&
      if grep -q '^CC = gcc$' config.make
      then
         print_info "Removing config.status for later configure..."
         rm config.status
      else :
      fi &&
         cd ..
   }

   compile_first_glibc() {
      print_info "Installing glibc (first pass)" &&
         mkdir -p "$GLIBC_SRC".first_obj &&
         cd "$GLIBC_SRC".first_obj &&
         BUILD_CC="gcc" CC="$TARGET"-gcc \
         AR="$TARGET"-ar RANLIB="$TARGET"-ranlib \
         ../$GLIBC_SRC/configure \
         --with-binutils=${ROOT}/bin \
         --build="$HOST" \
         --host="$TARGET" \
         --prefix="$SYS_ROOT" \
         --with-headers="$SYS_ROOT"/include \
         --cache-file=config.cache \
         --enable-obsolete-rpc \
         --disable-profile \
         --enable-add-ons=libpthread \
         --enable-obsolete-rpc \
         --disable-nscd &&
         PATH=$ROOT/bin:$PATH \
         make -j$PROCS all install &&
         cd ..
   }

   compile_full_gcc () {
      print_info "Cross compiling GCC"
      rm -rf "$GCC_SRC".obj &&
         mkdir -p "$GCC_SRC".obj &&
         cd "$GCC_SRC".obj &&
         AR=ar LDFLAGS="-Wl,-rpath,${ROOT}/lib" \
         ../$GCC_SRC/configure \
         --prefix="$ROOT" \
         --target="$TARGET" \
         --with-sysroot="$SYSTEM" \
         --with-local-prefix="$SYS_ROOT" \
         --with-native-system-header-dir="$SYS_ROOT"/include \
         --disable-static \
         --disable-nls \
         --enable-languages=c,c++ \
         --enable-threads=posix \
         --disable-multilib \
         --with-system-zlib \
         --with-libstdcxx-time \
      	 --disable-libcilkrts \
         --with-arch=i586 &&
         make AS_FOR_TARGET="${TARGET}-as" \
         LD_FOR_TARGET="${TARGET}-ld" -j$PROCS all &&
         make install &&
         cd ..
   }

   compile_second_glibc() {
      print_info "Installing GLibC (second pass)" &&
         mkdir -p "$GLIBC_SRC".second_obj &&
         cd "$GLIBC_SRC".second_obj &&
         rm -f config.cache &&
         BUILD_CC="gcc" CC="$TARGET"-gcc \
         AR="$TARGET"-ar RANLIB="$TARGET"-ranlib \
         ../$GLIBC_SRC/configure \
         --with-binutils=${ROOT}/bin \
         --build="$HOST" \
         --host="$TARGET" \
         --prefix="$SYS_ROOT" \
         --with-headers="$SYS_ROOT"/include \
         --enable-obsolete-rpc \
         --disable-profile \
         --enable-add-ons=libpthread \
         --enable-obsolete-rpc \
         --disable-nscd &&
         make -j$PROCS all install &&
         cd ..
}

compile_pkgconfiglite() {
   cd "$PKGCONFIGLITE_SRC" &&
      ./configure --prefix="$ROOT" --host=${TARGET}\
      --with-pc-path="/sys/lib/pkgconfig:/sys/share/pkgconfig" &&
      make all install && cd ..
}

print_info "Root is $ROOT"
print_info "Cross-compiling on $HOST to $TARGET"

mkdir -p "$SYSTEM" && cd "$SYSTEM" &&
   mkdir -p bin src boot "tools/include" "tools/lib" "cross-tools/$TARGET" &&
   ln -sfn "$SYS_ROOT"/include "$SYS_ROOT"/lib "$ROOT"/"$TARGET"/ &&
   rm -f /tools /cross-tools &&
   ln -sf $PWD/tools /tools &&
   ln -sf $PWD/cross-tools /cross-tools &&

   cd src &&
   compile_binutils &&
   compile_gcc &&
   compile_pkgconfiglite &&
   install_gnumach_headers &&
   install_gnumig &&
   install_hurd_headers &&
   compile_first_glibc &&
   compile_full_gcc &&
   compile_second_glibc &&
   exit 0
