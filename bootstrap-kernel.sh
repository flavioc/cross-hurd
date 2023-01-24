#!/bin/sh

. ./vars.sh
. ./download-funcs.sh
. ./bootstrap-funcs.sh

print_info "Root is $ROOT"
print_info "Cross-compiling on $HOST to $TARGET"

setup_directories

install_gnumach() {
   cd $SOURCE/$GNUMACH_SRC &&
   autoreconf -i &&
   cd - &&
   rm -rf $GNUMACH_SRC.obj &&
   mkdir -p $GNUMACH_SRC.obj &&
   cd $GNUMACH_SRC.obj &&
   $SOURCE/$GNUMACH_SRC/configure \
      --host="$TARGET" \
      --build="$HOST" \
      --exec-prefix=$SYSTEM \
      --enable-kdb \
      --enable-kmsg \
      --prefix="$SYS_ROOT" &&
   make -j$PROCS gnumach.gz gnumach gnumach.msgids &&
   make -j$PROCS install &&
   mkdir -p $SYSTEM/boot &&
   cp gnumach.gz $SYSTEM/boot/ &&
   cd -
}

set_vars() {
   export CC="${TARGET}-gcc"
   export CXX="${TARGET}-g++"
   export AR="${ROOT}/bin/${TARGET}-ar"
   export AS="${ROOT}/bin/${TARGET}-as"
   export RANLIB="${ROOT}/bin/${TARGET}-ranlib"
   export LD="${ROOT}/bin/${TARGET}-ld"
   export STRIP="${ROOT}/bin/${TARGET}-strip"
   export MIG="${ROOT}/bin/${TARGET}-mig"
}

mkdir -p $BUILD_ROOT/bootstrap-kernel &&
   cd $BUILD_ROOT/bootstrap-kernel &&
   compile_binutils &&
   compile_gcc &&
   compile_pkgconfiglite &&
   install_gnumach_headers &&
   install_gnumig &&
   set_vars &&
   install_gnumach &&
   print_info "bootstrap.sh finished successfully" &&
   exit 0
