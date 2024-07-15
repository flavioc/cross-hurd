#!/bin/sh

. ./vars.sh
. ./download-funcs.sh
. ./bootstrap-funcs.sh

print_info "Root is $CROSS_TOOLS"
print_info "Cross-compiling on $HOST to $CROSS_HURD_TARGET"

setup_directories

install_gnumach() {
   cd $SOURCE/$GNUMACH_SRC &&
      autoreconf -i &&
      cd - &&
      rm -rf $GNUMACH_SRC.obj &&
      mkdir -p $GNUMACH_SRC.obj &&
      cd $GNUMACH_SRC.obj &&
      local disable_user32=""
   local user_mig=""
   local user_cc
   if [ ! -z "$USER32" ]; then
      enable_user32="--enable-user32"
      user_mig=/cross-tools-i686/bin/i686-gnu-mig
      user_cc=/cross-tools-i686/bin/i686-gnu-gcc
      user_cpp="$user_cc -E"
   else
      user_mig=$CROSS_TOOLS/bin/x86_64-gnu-mig
      user_cc=$CROSS_TOOLS/bin/x86_64-gnu-gcc
      user_cpp="$user_cc -E"
   fi &&
      USER_CC="$user_cc" USER_CPP="$user_cpp" \
         USER_MIG="$user_mig" $SOURCE/$GNUMACH_SRC/configure \
         --host="$CROSS_HURD_TARGET" \
         --build="$HOST" \
         --exec-prefix=$SYSTEM \
         --enable-kdb \
         --enable-kmsg \
         --prefix="$SYS_ROOT" \
         $enable_user32 &&
      make -j$PROCS gnumach.gz gnumach gnumach.msgids &&
      make -j$PROCS install &&
      mkdir -p $SYSTEM/boot &&
      cp gnumach.gz $SYSTEM/boot/ &&
      cd -
}

set_vars() {
   export CC="${CROSS_HURD_TARGET}-gcc"
   export CXX="${CROSS_HURD_TARGET}-g++"
   export AR="${CROSS_TOOLS}/bin/${CROSS_HURD_TARGET}-ar"
   export AS="${CROSS_TOOLS}/bin/${CROSS_HURD_TARGET}-as"
   export RANLIB="${CROSS_TOOLS}/bin/${CROSS_HURD_TARGET}-ranlib"
   export LD="${CROSS_TOOLS}/bin/${CROSS_HURD_TARGET}-ld"
   export STRIP="${CROSS_TOOLS}/bin/${CROSS_HURD_TARGET}-strip"
   export MIG="${CROSS_TOOLS}/bin/${CROSS_HURD_TARGET}-mig"
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
