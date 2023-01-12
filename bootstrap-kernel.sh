#!/bin/sh

. ./vars.sh
. ./download-funcs.sh
. ./common.sh
. ./bootstrap-funcs.sh

print_info "Root is $ROOT"
print_info "Cross-compiling on $HOST to $TARGET"

setup_directories

install_gnumach() {
   cd "$GNUMACH_SRC" &&
   autoreconf -i &&
   cd .. &&
   rm -rf $GNUMACH_SRC.second_obj &&
   mkdir -p "$GNUMACH_SRC".second_obj &&
   cd "$GNUMACH_SRC".second_obj &&
   ../$GNUMACH_SRC/configure \
      --host="$TARGET" \
      --build="$HOST" \
      --exec-prefix=/tmp/throwitaway \
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

 cd src &&
   compile_binutils &&
   compile_gcc &&
   compile_pkgconfiglite &&
   install_gnumach_headers &&
   install_gnumig &&
   set_vars &&
   install_gnumach &&
   print_info "bootstrap.sh finished successfully" &&
   exit 0
