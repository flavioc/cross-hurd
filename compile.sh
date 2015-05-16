#!/bin/sh

BINUTILS_URL=http://ftp.gnu.org/gnu/binutils/binutils-2.25.tar.bz2

print_info ()
{
   echo "* $*"
}

. ./vars.sh

compile_binutils ()
{
   print_info "Cross compiling binutils"
mkdir -p "$BINUTILS_SRC".obj &&
cd "$BINUTILS_SRC".obj &&
AR=ar AS=as ../$BINUTILS_SRC/configure \
   --target="$TARGET" \
   --prefix="$ROOT" \
   --with-sysroot="$SYS_ROOT" \
   --disable-static \
   --with-lib-path="$ROOT"/lib \
   --disable-multilib \
   --disable-werror \
   --disable-nls &&
   make -j$PROCS all install &&
   cd ..
}

compile_gcc ()
{
   print_info "Cross compiling first phase of GCC"
mkdir -p "$GCC_SRC".obj &&
cd "$GCC_SRC".obj &&
AR=ar LDFLAGS="-Wl,-rpath,${ROOT}/lib" \
../$GCC_SRC/configure \
   --prefix="$ROOT" \
   --build="$HOST" \
   --host="$HOST" \
   --target="$TARGET" \
   --with-sysroot="$SYS_ROOT" \
   --with-local-prefix="$ROOT" \
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
   PATH=$PATH:$ROOT/bin ../$GNUMIG_SRC/configure --target="$TARGET" \
      --prefix="$ROOT" &&
   PATH=$PATH:$ROOT/bin make -j$PROCS all install &&
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
   mkdir -p "$GLIBC_SRC".obj &&
   cd "$GLIBC_SRC".obj &&
   BUILD_CC="gcc" CC="$TARGET"-gcc \
   AR="$TARGET"-ar RANLIB="$TARGET"-ranlib \
   ../$GLIBC_SRC/configure \
      --with-binutils=${ROOT}/bin \
      --build="$HOST" \
      --host="$TARGET" \
      --prefix="$ROOT" \
      --with-headers="$SYS_ROOT"/include \
      --cache-file=config.cache \
      --enable-obsolete-rpc \
      --disable-profile \
      --enable-add-ons=libpthread \
      --enable-obsolete-rpc \
      --disable-nscd &&
   PATH=$ROOT/bin:$PATH \
   make -j$PROCS install_root="$SYS_ROOT" all install &&
   cd ..
}

print_info "Root is $ROOT"
print_info "Cross-compiling on $HOST to $TARGET"

mkdir -p "$ROOT" && cd "$ROOT" &&
   mkdir -p bin src "$SYS_ROOT/include" "$SYS_ROOT/lib" "$TARGET" &&
   ln -sfn "$SYS_ROOT/include" "$SYS_ROOT/lib" "$TARGET"/ &&

cd src &&
compile_binutils &&
compile_gcc &&
install_gnumach_headers &&
install_gnumig &&
install_hurd_headers &&
compile_first_glibc

