#!/bin/sh

BINUTILS_URL=http://ftp.gnu.org/gnu/binutils/binutils-2.25.tar.bz2

print_info ()
{
   echo "* $*"
}

. ./vars.sh

compile_binutils ()
{
mkdir -p "$BINUTILS_SRC".obj &&
cd "$BINUTILS_SRC".obj &&
../$BINUTILS_SRC/configure \
   --target="$TARGET" \
   --prefix="$ROOT" \
   --with-sysroot="$SYS_ROOT" \
   --disable-nls &&
   make all install &&
cd ..
}

compile_gcc ()
{
mkdir -p "$GCC_SRC".obj &&
cd "$GCC_SRC".obj &&
../$GCC_SRC/configure \
   --target="$TARGET" \
   --prefix="$ROOT" \
   --with-sysroot="$SYS_ROOT" \
   --disable-nls \
   --disable-shared \
   --disable-threads \
   --without-headers \
   --with-newlib \
   --enable-languages=c &&
   make all-gcc install-gcc &&
   make configure-target-libgcc &&
   cd "$TARGET"/libgcc &&
   make 'libgcc-objects = $(lib2funcs-o) $(lib2-divmod-o)' all install &&
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
   make install-data &&
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
   PATH=$PATH:$ROOT/bin make all install &&
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
   make prefix="$SYS_ROOT" no_deps=t install-headers &&
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
   PATH=$ROOT/bin:$PATH \
   BUILD_CC="gcc" CC="$TARGET"-gcc \
   AR="$TARGET"-ar RANLIB="$TARGET"-ranlib \
   ../$GLIBC_SRC/configure \
      --without-cvs \
      --with-binutils=${TARGET}/bin \
      --build="$(../"$GLIBC_SRC"/scripts/config.guess)" \
      --host="$TARGET" \
      --prefix= \
      --with-headers="$SYS_ROOT"/include \
      --enable-obsolete-rpc \
      --disable-profile \
      --enable-add-ons=libpthread \
      --disable-multi-arch \
      --enable-obsolete-rpc \
      --disable-nscd \
      --with-arch=i586 &&
   PATH=$ROOT/bin:$PATH \
   make install_root="$SYS_ROOT" all install &&
   cd ..
}

print_info "Root is $ROOT"
print_info "Cross-compiling on $HOST to $TARGET"

mkdir -p "$ROOT" && cd "$ROOT" &&
   mkdir -p bin src "$SYS_ROOT/include" "$SYS_ROOT/lib" "$TARGET" &&
   ln -sfn "$SYS_ROOT/include" "$SYS_ROOT/lib" "$TARGET"/ &&

cd src &&
#compile_binutils &&
#compile_gcc &&
#install_gnumach_headers &&
#install_gnumig &&
#install_hurd_headers &&
compile_first_glibc

