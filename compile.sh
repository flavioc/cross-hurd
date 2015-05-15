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
   cd ..
}

print_info "Root is $ROOT"
print_info "Cross-compiling on $HOST to $TARGET"

mkdir -p "$ROOT" && cd "$ROOT" &&
   mkdir -p bin src "$SYS_ROOT/include" "$SYS_ROOT/lib" "$TARGET" &&
   ln -sfn "$SYS_ROOT/include" "$SYS_ROOT/lib" "$TARGET"/ &&

cd src &&

# Install the cross GNU Binutils.
compile_binutils &&

# Install the minimal cross GCC to build a cross MIG and the GNU C library.
compile_gcc

