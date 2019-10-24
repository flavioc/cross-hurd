#!/bin/sh

. ./vars.sh
. ./download-funcs.sh
. ./common.sh
# You can change the GCC version here.
export CC="$HOST_MACHINE"-gcc
export CXX="$HOST_MACHINE"-g++

compile_binutils ()
{
   print_info "Cross compiling binutils"
   rm -rf "$BINUTILS_SRC".obj &&
   mkdir -p "$BINUTILS_SRC".obj &&
   cd "$BINUTILS_SRC".obj &&
   AR="$HOST_MACHINE-ar" AS="$HOST_MACHINE-as" \
   ../$BINUTILS_SRC/configure \
      --host="$HOST" \
      --target="$TARGET" \
      --prefix="$ROOT" \
      --with-sysroot="$SYSTEM" \
      --disable-static \
      --with-lib-path="$SYS_ROOT"/lib \
      --disable-multilib \
      --disable-werror \
      --disable-nls &&
   make -j$PROCS all &&
   make install &&
   cd ..
}

unpack_gcc_and_fix() {
   if [ -d "$GCC_SRC" ]; then
      rm -rf "$GCC_SRC"
   fi
   unpack_gcc &&
   cd "$GCC_SRC" && fix_gcc_path && cd ..
}

compile_gcc ()
{
   print_info "Cross compiling first phase of GCC"
   unpack_gcc_and_fix &&
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
      --disable-decimal-float \
      --disable-threads \
      --disable-libatomic \
      --disable-libgomp \
      --disable-libquadmath \
      --disable-libssp \
      --disable-libvtv \
      --disable-libstdcxx \
      --enable-languages=c &&
   make -j$PROCS all-gcc &&
   make install-gcc &&
   make -j$PROCS configure-target-libgcc &&
   cd "$TARGET"/libgcc &&
   make -j$PROCS 'libgcc-objects = $(lib2funcs-o) $(lib2-divmod-o)' all &&
   make 'libgcc-objects = $(lib2funcs-o) $(lib2-divmod-o)' install &&
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
   rm -rf "$GNUMIG_SRC".obj &&
   mkdir -p "$GNUMIG_SRC".obj &&
   cd "$GNUMIG_SRC".obj &&
   ../$GNUMIG_SRC/configure --target="$TARGET" \
      --prefix="$ROOT" &&
   make -j$PROCS &&
   make install &&
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
   rm -rf "$GLIBC_SRC".first_obj &&
   mkdir -p "$GLIBC_SRC".first_obj &&
   cd "$GLIBC_SRC".first_obj &&
   BUILD_CC="$HOST_MACHINE-gcc" CC="$TARGET"-gcc \
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
      --disable-werror \
      --disable-nscd &&
   make -j$PROCS &&
   make install &&
   cd ..
}

compile_full_gcc () {
   print_info "Cross compiling GCC"
   unpack_gcc_and_fix
   rm -rf "$GCC_SRC".obj &&
   mkdir -p "$GCC_SRC".obj &&
   cd "$GCC_SRC".obj &&
   AR="$HOST_MACHINE-ar" \
   LDFLAGS="-Wl,-rpath,${ROOT}/lib" \
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
      --disable-libstdcxx-pch \
      --disable-bootstrap \
      --disable-libcilkrts \
      --disable-libgomp \
      --with-arch=$CPU &&
   make -j$PROCS AS_FOR_TARGET="$TARGET-as" LD_FOR_TARGET="$TARGET-ld" all &&
   make install &&
   cd ..
}

compile_second_glibc() {
   print_info "Installing GLibC (second pass)" &&
   rm -rf "$GLIBC_SRC".second_obj &&
   mkdir -p "$GLIBC_SRC".second_obj &&
   cd "$GLIBC_SRC".second_obj &&
   rm -f config.cache &&
   BUILD_CC="$HOST_MACHINE-gcc" CC="$TARGET"-gcc \
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
      --disable-werror \
      --disable-nscd &&
   make -j$PROCS &&
   make install &&
   cd ..
}

compile_pkgconfiglite() {
   cd "$PKGCONFIGLITE_SRC" &&
   # otherwise "ln pkg-config i586-pc-gnu-pkg-config" in the install step fails
   rm -fv "$ROOT"/bin/i586-pc-gnu-pkg-config &&
   ./configure --prefix="$ROOT" --host=${TARGET}\
      --with-pc-path="/sys/lib/pkgconfig:/sys/share/pkgconfig" &&
   make -j$PROCS &&
   make  install &&
   cd ..
}

print_info "Root is $ROOT"
print_info "Cross-compiling on $HOST to $TARGET"

create_tools_symlink() {
    set -x
    if [ $(readlink /tools) != "$PWD/tools" ]; then
        sudo rm -f /tools
        sudo ln -sf "$PWD"/tools /tools
    fi
    if [ $(readlink /cross-tools) != "$PWD/cross-tools" ]; then
        sudo rm -f /cross-tools
        sudo ln -sf "$PWD"/cross-tools /cross-tools
    fi
    set +x
}

mkdir -p "$SYSTEM" && cd "$SYSTEM" &&
   mkdir -p bin src boot "tools/include" "tools/lib" "cross-tools/$TARGET" &&
   create_tools_symlink &&
   ln -sfn "$SYS_ROOT"/include "$SYS_ROOT"/lib "$ROOT"/"$TARGET"/ &&

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
   print_info "bootstrap.sh finished successfully" &&
   exit 0
