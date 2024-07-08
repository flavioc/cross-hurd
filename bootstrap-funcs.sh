#!/bin/sh
#
export CC=$HOST_CC
export CXX=$HOST_CXX

compile_binutils ()
{
   print_info "Cross compiling binutils"
   rm -rf "$BINUTILS_SRC".obj &&
   mkdir -p "$BINUTILS_SRC".obj &&
   cd "$BINUTILS_SRC".obj &&
   AR=$HOST_AR AS=$HOST_AS \
   $SOURCE/$BINUTILS_SRC/configure \
      --host="$HOST" \
      --target="$CROSS_HURD_TARGET" \
      --prefix="$CROSS_TOOLS" \
      --with-sysroot="$SYSTEM" \
      --disable-static \
      --with-lib-path="$SYS_ROOT"/lib \
      --disable-multilib \
      --disable-nls &&
   make -j$PROCS all &&
   make -j$PROCS install &&
   cd ..
}

compile_gcc ()
{
   print_info "Cross compiling first phase of GCC"
   rm -rf $GCC_SRC.obj &&
   mkdir -p $GCC_SRC.obj &&
   cd $GCC_SRC.obj &&
   AR=$HOST_AR LDFLAGS="-Wl,-rpath,${CROSS_TOOLS}/lib" \
   $SOURCE/$GCC_SRC/configure \
      --prefix=$CROSS_TOOLS \
      --build="$HOST" \
      --host="$HOST" \
      --target="$CROSS_HURD_TARGET" \
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
   make -j$PROCS install-gcc &&
   make -j$PROCS configure-target-libgcc &&
   cd "$CROSS_HURD_TARGET"/libgcc &&
   make -j$PROCS all &&
   make -j$PROCS install &&
   cd - &&
   mv config.status config.status.removed &&
   rm -f config.cache *config.cache */*/config.cache &&
   cd ..
}

install_gnumach_headers() {
   print_info "Installing GNU Mach Headers" &&
   cd $SOURCE/$GNUMACH_SRC &&
   autoreconf -i &&
   cd - &&
   mkdir -p "$GNUMACH_SRC".obj &&
   local disable_user32=""
   if [ -z "$USER32" ]; then
      disable_user32="--disable-user32"
   fi
   cd "$GNUMACH_SRC".obj &&
      $SOURCE/$GNUMACH_SRC/configure \
      --host="$CROSS_HURD_TARGET" \
      --prefix="$SYS_ROOT" \
      $disable_user32 &&
   make -j$PROCS install-data &&
   cd ..
}

install_gnumig() {
   print_info "Installing cross GNU Mig" &&
   cd $SOURCE/$GNUMIG_SRC &&
   autoreconf -i &&
   cd - &&
   rm -rf $GNUMIG_SRC.host_obj &&
   mkdir -p $GNUMIG_SRC.host_obj &&
   cd $GNUMIG_SRC.host_obj &&
   $SOURCE/$GNUMIG_SRC/configure --target="$CROSS_HURD_TARGET" \
      --prefix=$CROSS_TOOLS &&
   make -j$PROCS &&
   make -j$PROCS check &&
   make -j$PROCS install &&
   cd ..
}

install_hurd_headers() {
   print_info "Installing Hurd headers" &&
   cd $SOURCE/$HURD_SRC &&
   autoreconf -i &&
   cd - &&
   rm -rf $HURD_SRC.obj &&
   mkdir -p $HURD_SRC.obj &&
   cd $HURD_SRC.obj &&
   $SOURCE/$HURD_SRC/configure \
      --host="$CROSS_HURD_TARGET" \
      --target="$CROSS_HURD_TARGET" \
      --prefix= \
      --disable-profile \
      --without-libbz2 \
      --without-libz \
      --without-rump \
      --disable-ncursesw \
      --without-parted &&
   make -j$PROCS prefix="$SYS_ROOT" no_deps=t install-headers &&
   cd ..
}

compile_first_glibc() {
   print_info "Installing glibc (first pass)" &&
   rm -rf $GLIBC_SRC.first_obj &&
   mkdir -p $GLIBC_SRC.first_obj &&
   cd $GLIBC_SRC.first_obj &&
   BUILD_CC=$HOST_CC CC=$CROSS_HURD_TARGET-gcc \
   AR=$CROSS_HURD_TARGET-ar CXX="cxx-not-found" RANLIB=$CROSS_HURD_TARGET-ranlib \
   $SOURCE/$GLIBC_SRC/configure \
      --with-binutils=${CROSS_TOOLS}/bin \
      --build="$HOST" \
      --host="$CROSS_HURD_TARGET" \
      --prefix="$SYS_ROOT" \
      --with-headers="$SYS_ROOT"/include \
      --cache-file=config.cache \
      --enable-obsolete-rpc \
      --disable-profile \
      --enable-add-ons=libpthread \
      --enable-obsolete-rpc \
      --disable-nscd \
      libc_cv_ctors_header=yes &&
   make -j$PROCS || # workaround for "fails first time"?
   make -j$PROCS &&
   make -j$PROCS install &&
   cd ..
}

compile_full_gcc () {
   print_info "Cross compiling GCC"
   rm -rf $GCC_SRC.obj &&
   mkdir -p $GCC_SRC.obj &&
   cd $GCC_SRC.obj &&
   AR=$HOST_AR \
   LDFLAGS="-Wl,-rpath,${CROSS_TOOLS}/lib" \
   $SOURCE/$GCC_SRC/configure \
      --prefix=$CROSS_TOOLS \
      --target="$CROSS_HURD_TARGET" \
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
      --disable-libgomp &&
   make -j$PROCS AS_FOR_TARGET="$CROSS_HURD_TARGET-as" LD_FOR_TARGET="$CROSS_HURD_TARGET-ld" all &&
   make -j$PROCS install &&
   cd ..
}

compile_second_glibc() {
   print_info "Installing GLibC (second pass)" &&
   rm -rf $GLIBC_SRC.second_obj &&
   mkdir -p $GLIBC_SRC.second_obj &&
   cd $GLIBC_SRC.second_obj &&
   rm -f config.cache &&
   BUILD_CC=$HOST_CC CC=$CROSS_HURD_TARGET-gcc CXX="" \
   AR=$CROSS_HURD_TARGET-ar RANLIB=$CROSS_HURD_TARGET-ranlib \
   $SOURCE/$GLIBC_SRC/configure \
      --with-binutils=$CROSS_TOOLS/bin \
      --build="$HOST" \
      --host="$CROSS_HURD_TARGET" \
      --prefix="$SYS_ROOT" \
      --with-headers="$SYS_ROOT"/include \
      --enable-obsolete-rpc \
      --disable-profile \
      --enable-add-ons=libpthread \
      --enable-obsolete-rpc \
      --disable-nscd &&
   make -j$PROCS &&
   make -j$PROCS install &&
   cd ..
}

compile_pkgconfiglite() {
   # otherwise "ln pkg-config i586-pc-gnu-pkg-config" in the install step fails
   rm -fv $CROSS_TOOLS/bin/*-pkg-config &&
   rm -rf $PKGCONFIGLITE_SRC.obj &&
   mkdir -p $PKGCONFIGLITE_SRC.obj &&
   cd $PKGCONFIGLITE_SRC.obj &&
   $SOURCE/$PKGCONFIGLITE_SRC/configure \
      --prefix=$CROSS_TOOLS --host=$CROSS_HURD_TARGET \
      --with-pc-path=$SYS_ROOT/lib/pkgconfig &&
   make -j$PROCS &&
   make -j$PROCS install &&
   cd ..
}

create_tools_symlink() {
    if [ ! -e $SYS_ROOT ]; then
       sudo ln -sf "$PWD"/$(basename $SYS_ROOT) $SYS_ROOT
    fi
    if [ ! -e $CROSS_TOOLS ]; then
       sudo ln -sf "$PWD"/$(basename $CROSS_TOOLS) $CROSS_TOOLS
    fi
}

setup_directories() {
   mkdir -p "$SYSTEM" && cd "$SYSTEM" &&
   mkdir -p bin boot "$(basename $SYS_ROOT)/include" "$(basename $SYS_ROOT)/lib" "$(basename $CROSS_TOOLS)/$CROSS_HURD_TARGET" &&
	create_tools_symlink &&
	ln -sfn $SYS_ROOT/include $SYS_ROOT/lib $CROSS_TOOLS/$CROSS_HURD_TARGET/ &&
   cd -
}
