#!/bin/sh

. ./vars.sh
. ./download-funcs.sh
. ./bootstrap-funcs.sh

print_info "Root is $CROSS_TOOLS"
print_info "Cross-compiling on $HOST to $TARGET"

setup_directories

install_gnumach() {
   cd $SOURCE/$GNUMACH_SRC &&
   autoreconf -i &&
   cd - &&
   rm -rf $GNUMACH_SRC.obj &&
   mkdir -p $GNUMACH_SRC.obj &&
   cd $GNUMACH_SRC.obj &&
   local disable_user32=""
   local mig_location=""
   if [ -z "$USER32" ]; then
      disable_user32="--disable-user32"
      mig_location=$CROSS_TOOLS/bin/x86_64-gnu-mig
   else
      mig_location=/cross-tools-i686/bin/i686-gnu-mig
   fi &&
   MIGUSER=$mig_location $SOURCE/$GNUMACH_SRC/configure \
      --host="$TARGET" \
      --build="$HOST" \
      --exec-prefix=$SYSTEM \
      --enable-kdb \
      --enable-kmsg \
      --prefix="$SYS_ROOT" \
      $disable_user32 &&
   make -j$PROCS gnumach.gz gnumach gnumach.msgids &&
   make -j$PROCS install &&
   mkdir -p $SYSTEM/boot &&
   cp gnumach.gz $SYSTEM/boot/ &&
   cd -
}

set_vars() {
   export CC="${TARGET}-gcc"
   export CXX="${TARGET}-g++"
   export AR="${CROSS_TOOLS}/bin/${TARGET}-ar"
   export AS="${CROSS_TOOLS}/bin/${TARGET}-as"
   export RANLIB="${CROSS_TOOLS}/bin/${TARGET}-ranlib"
   export LD="${CROSS_TOOLS}/bin/${TARGET}-ld"
   export STRIP="${CROSS_TOOLS}/bin/${TARGET}-strip"
   export MIG="${CROSS_TOOLS}/bin/${TARGET}-mig"
}

mkdir -p $BUILD_ROOT/bootstrap-kernel &&
   cd $BUILD_ROOT/bootstrap-kernel &&
   if [ ! "$1" = "--kernel-only" ]; then
   compile_binutils &&
   compile_gcc &&
   compile_pkgconfiglite &&
   install_gnumach_headers &&
   install_gnumig
   fi &&
   set_vars &&
   install_gnumach &&
   print_info "bootstrap-kernel.sh finished successfully" &&
   exit 0
