#!/bin/sh

. ./vars.sh
. ./download-funcs.sh
. ./bootstrap-funcs.sh

print_info "Root is $ROOT"
print_info "Cross-compiling on $HOST to $TARGET"

setup_directories

mkdir -p $BUILD_ROOT/bootstrap &&
   cd $BUILD_ROOT/bootstrap &&
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
