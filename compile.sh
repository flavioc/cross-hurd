#!/bin/sh

. ./vars.sh
. ./download-funcs.sh
export CC="$CROSS_TOOLS/bin/${TARGET}-gcc"
export CXX="$CROSS_TOOLS/bin/${TARGET}-g++"
export AR="$CROSS_TOOLS/bin/${TARGET}-ar"
export AS="$CROSS_TOOLS/bin/${TARGET}-as"
export RANLIB="$CROSS_TOOLS/bin/${TARGET}-ranlib"
export LD="$CROSS_TOOLS/bin/${TARGET}-ld"
export STRIP="$CROSS_TOOLS/bin/${TARGET}-strip"
export MIG="$CROSS_TOOLS/bin/${TARGET}-mig"

install_flex() {
   mkdir -p $FLEX_SRC.obj &&
   cd $FLEX_SRC.obj &&
   ac_cv_func_realloc_0_nonnull=yes ac_cv_func_malloc_0_nonnull=yes \
   $SOURCE/$FLEX_SRC/configure --prefix="$SYS_ROOT" \
      --build="$HOST" \
      --host="$TARGET" &&
   sed -i -e 's/tests//' Makefile &&
   make -j$PROCS all &&
   make -j$PROCS install &&
   cd ..
}

install_mig() {
   cd $SOURCE/$GNUMIG_SRC &&
   autoreconf -i &&
   cd - &&
   rm -rf $GNUMIG_SRC.obj &&
   mkdir -p "$GNUMIG_SRC".obj &&
   cd "$GNUMIG_SRC".obj &&
   $SOURCE/$GNUMIG_SRC/configure \
      --build="$HOST" \
      --host="$TARGET" \
      --prefix="$SYS_ROOT" \
      --target="$TARGET" &&
   make clean &&
   make -j$PROCS all &&
   make -j$PROCS install &&
   cd ..
}

install_zlib() {
   mkdir -p $ZLIB_SRC.obj
   cd $ZLIB_SRC.obj &&
   $SOURCE/$ZLIB_SRC/configure --prefix=$SYS_ROOT &&
   make -j$PROCS &&
   make -j$PROCS install &&
   cd ..
}

install_bzip2() {
   echo $PATH
   rm -rf $BZIP2_SRC.obj &&
   cp -R $SOURCE/$BZIP2_SRC $BZIP2_SRC.obj &&
   pushd $BZIP2_SRC.obj &&
   # Ensure installation of symbolic links is relative.
   sed -i 's@\(ln -s -f \)$(PREFIX)/bin/@\1@' Makefile &&
   make -j$PROCS AR=$AR CC=$CC RANLIB=$RANLIB -f Makefile-libbz2_so &&
   make -j$PROCS clean &&
   make -j$PROCS CC=$CC AR=$AR RANLIB=$RANLIB bzip2 bzip2recover &&
   make -j$PROCS PREFIX=$SYS_ROOT install &&
   cp -v bzip2-shared $SYS_ROOT/bin/bzip2 &&
   cp -av libbz2.so* $SYS_ROOT/lib &&
   ln -fsv $SYS_ROOT/lib/libbz2.so.1.0 $SYS_ROOT/lib/libbz2.so &&
   popd
}

install_gpg_error() {
   cd $SOURCE/$GPG_ERROR_SRC &&
   ./autogen.sh &&
   cd - &&
   mkdir -p $GPG_ERROR_SRC.obj &&
   cd $GPG_ERROR_SRC.obj &&
   $SOURCE/$GPG_ERROR_SRC/configure --prefix=$SYS_ROOT \
      --build="$HOST" \
      --host="$TARGET" &&
   make -j$PROCS &&
   make -j$PROCS install &&
   cd ..
}

install_gcrypt() {
   mkdir -p $GCRYPT_SRC.obj &&
   cd $GCRYPT_SRC.obj &&
   $SOURCE/$GCRYPT_SRC/configure --prefix=$SYS_ROOT \
      --build="$HOST" \
      --host="$TARGET" \
      --disable-padlock-support \
      --with-gpg-error-prefix="$SYS_ROOT" \
      --disable-asm &&
   make -j$PROCS &&
   make -j$PROCS install &&
   cd ..
}

install_gnumach() {
   print_info "Compiling GNUMach kernel"
   cd $SOURCE/$GNUMACH_SRC &&
   autoreconf -i &&
   cd - &&
   mkdir -p $GNUMACH_SRC.obj &&
   cd $GNUMACH_SRC.obj &&
   local disable_user32=""
   local mig_location
   if [ -z "$USER32" ]; then
      disable_user32="--disable-user32"
      mig_location=$CROSS_TOOLS/bin/x86_64-gnu-mig
   else
      mig_location=/cross-tools-i686/bin/i686-gnu-mig
   fi &&
   CFLAGS="-O2 -Wall -g -pipe -fno-strict-aliasing -no-pie -fno-PIE -fno-pie -Wformat -Werror=format-security" \
   LDFLAGS="-no-pie" \
   MIGUSER=$mig_location $SOURCE/$GNUMACH_SRC/configure \
      --host="$TARGET" \
      --build="$HOST" \
      --exec-prefix=/tmp/throwitaway \
      --enable-kdb \
      --enable-kmsg \
      --prefix="$SYS_ROOT" \
      --disable-net-group \
      --disable-pcmcia-group \
      --disable-wireless-group \
      $disable_user32 &&
   make clean &&
   make -j$PROCS gnumach.gz gnumach gnumach.msgids &&
   make -j$PROCS install &&
   mkdir -p $SYSTEM/boot &&
   cp gnumach{,.gz} $SYSTEM/boot/ &&
   cd -
}

install_hurd() {
   print_info "Compiling Hurd servers..."
   pushd $SOURCE/$HURD_SRC &&
   autoreconf -i &&
   popd &&
   local extra_flags="$1"
   mkdir -p $HURD_SRC.obj &&
   pushd $HURD_SRC.obj &&
   $SOURCE/$HURD_SRC/configure \
      --build=$HOST \
      --host=$TARGET \
      --prefix=$SYS_ROOT \
      --with-libgcrypt-prefix=$SYS_ROOT \
      --enable-static-progs='ext2fs,iso9660fs,rumpdisk,pci-arbiter,acpi' \
      --disable-profile \
      $extra_flags &&
   make -j$PROCS clean &&
   make -j$PROCS all &&
   fakeroot make -j$PROCS install &&
   (if [ -z "$extra_flags" ]; then
     make -j$PROCS libddekit &&
     make -j$PROCS libmachdevdde &&
     fakeroot make -j$PROCS -C libddekit install &&
     fakeroot make -j$PROCS -C libmachdevdde install
   fi) &&
   popd
}

install_binutils ()
{
   print_info "Compiling binutils"
   rm -rf $BINUTILS_SRC.obj &&
   mkdir -p $BINUTILS_SRC.obj &&
   cd $BINUTILS_SRC.obj &&
      $SOURCE/$BINUTILS_SRC/configure \
      --prefix="$SYS_ROOT" \
      --build="$HOST" \
      --host="$TARGET" \
      --target="$TARGET" \
      --with-lib-path="$SYS_ROOT"/lib \
      --disable-nls \
      --enable-shared \
      --disable-multilib &&
   make -j$PROCS all &&
   make -j$PROCS install &&
   cd ..
}

install_bash() {
   rm -rf $BASH_SRC.obj &&
   mkdir -p $BASH_SRC.obj &&
   cd $BASH_SRC.obj &&
      export CFLAGS="$CFLAGS -fcommon"
      cat > config.cache << "EOF"
ac_cv_func_mmap_fixed_mapped=yes
ac_cv_func_strcoll_works=yes
ac_cv_func_working_mktime=yes
bash_cv_func_sigsetjmp=present
bash_cv_getcwd_malloc=yes
bash_cv_job_control_missing=present
bash_cv_printf_a_format=yes
bash_cv_sys_named_pipes=present
bash_cv_ulimit_maxfds=yes
bash_cv_under_sys_siglist=yes
bash_cv_unusable_rtsigs=no
gt_cv_int_divbyzero_sigfpe=yes
EOF
   $SOURCE/$BASH_SRC/configure --prefix="$SYS_ROOT" \
      --build="$HOST" --host="$TARGET" \
      --without-bash-malloc --cache-file=config.cache &&
   make -j$PROCS &&
   make -j$PROCS install &&
   cd ..
}

install_dash () {
   rm -f $DASH_SRC.obj &^
   mkdir -p $DASH_SRC.obj &&
   pushd $DASH_SRC.obj &&
   $SOURCE/$DASH_SRC/configure --prefix=$SYS_ROOT \
      --build=$HOST --host=$TARGET
   make -j$PROCS &&
      make -j$PROCS install &&
   popd
}

install_coreutils() {
   mkdir -p $COREUTILS_SRC.obj &&
   cd $COREUTILS_SRC.obj &&
      cat > config.cache << EOF
fu_cv_sys_stat_statfs2_bsize=yes
gl_cv_func_working_mkstemp=yes
EOF
   $SOURCE/$COREUTILS_SRC/configure --prefix="$SYS_ROOT" \
      --build="$HOST" \
      --host="$TARGET" \
      --enable-install-program=hostname \
      --disable-year2038 \
      --cache-file=config.cache &&
   make -j$PROCS &&
   make -j$PROCS install &&
   cd ..
}

install_libuuid() {
   cd "$LIBUUID_SRC" &&
   ./configure --prefix="$SYS_ROOT" \
      --host="$HOST" \
      --target="$TARGET" &&
   make -j$PROCS && make -j$PROCS install &&
   cd ..
}

install_e2fsprogs() {
   rm -rf $E2FSPROGS_SRC.obj &&
   mkdir -p $E2FSPROGS_SRC.obj &&
   cd $E2FSPROGS_SRC.obj &&
   LDFLAGS="-luuid" $SOURCE/$E2FSPROGS_SRC/configure \
      --prefix="$SYS_ROOT" \
      --enable-elf-shlibs \
      --build=${HOST} \
      --host=${TARGET} \
      --disable-libblkid \
      --disable-libuuid  \
      --disable-uuidd &&
   make -j$PROCS && make -j$PROCS install && make -j$PROCS install-libs &&
   cd ..
}

install_util_linux() {
   mkdir -p $UTIL_LINUX_SRC.obj &&
   cd $UTIL_LINUX_SRC.obj &&
   $SOURCE/$UTIL_LINUX_SRC/configure --prefix="$SYS_ROOT" \
      --build="$HOST" \
      --host="$TARGET" \
      --disable-makeinstall-chown \
      --without-ncursesw \
      --disable-makeinstall-setuid  &&
   make -j$PROCS &&
   make -j$PROCS install &&
   cd ..
}

install_grub() {
   mkdir -p $GRUB_SRC.obj &&
   cd $GRUB_SRC.obj &&
   $SOURCE/$GRUB_SRC/configure --prefix="$SYS_ROOT" \
      --build=${HOST} \
      --host=${TARGET} \
      --disable-efiemu \
      --disable-werror \
      --enable-grub-mkfont=no \
      --with-bootdir=$SYS_ROOT/boot &&
   make -j$PROCS &&
   make -j$PROCS install &&
   cd ..
}

install_libxcrypt () {
   mkdir -p $LIBXCRYPT_SRC.obj &&
   cd $LIBXCRYPT_SRC.obj &&
   $SOURCE/$LIBXCRYPT_SRC/configure --prefix=$SYS_ROOT \
      --build=$HOST \
      --host=$TARGET \
      --enable-hashes=strong,glibc \
      --enable-obsolete-api=no \
      --disable-static \
      --disable-failure-tokens
   make -j$PROCS &&
   make -j $PROCS install &&
   cd ..
}

install_dmidecode () {
   rm -rf $DMIDECODE_SRC.obj &&
   cp -R $SOURCE/$DMIDECODE_SRC ./$DMIDECODE_SRC.obj &&
   pushd $DMIDECODE_SRC.obj &&
   make -j$PROCS &&
   make -j$PROCS install prefix=$SYS_ROOT &&
   popd
}

install_parted () {
   mkdir -p $PARTED_SRC.obj &&
   pushd $PARTED_SRC.obj &&
   $SOURCE/$PARTED_SRC/configure --prefix=$SYS_ROOT \
      --build=$HOST \
      --host=$TARGET \
      --disable-device-mapper \
      --enable-mtrace \
      --enable-shared \
      --without-readline &&
   make -j$PROCS &&
   make -j$PROCS install &&
   popd
}

install_shadow () {
   rm -rf $SHADOW_SRC.copy &&
   cp -R $SOURCE/$SHADOW_SRC $SHADOW_SRC.copy &&
   pushd $SHADOW_SRC.copy &&
   # Disable installation of some tools since they are provided by either
   # the Hurd itself or coreutils.
   sed -i -e 's/groups$(EXEEXT) //' \
       -e 's/= nologin$(EXEEXT)/= /' \
       -e 's/= login$(EXEEXT)/= /' \
       src/Makefile.in &&
   # Disable several manpages.
   find man -name Makefile.in -exec sed -i 's/groups\.1 / /'   {} \;
   find man -name Makefile.in -exec sed -i 's/getspnam\.3 / /' {} \;
   find man -name Makefile.in -exec sed -i 's/passwd\.5 / /'   {} \;
   sed -e 's:/var/spool/mail:/var/mail:'                   \
    -e '/PATH=/{s@/sbin:@@;s@/bin:@@}'                  \
    -i etc/login.defs &&
   apply_patch $SCRIPT_DIR/patches/shadow/shadow-utmp.patch 1 &&
   popd &&
   rm -rf $SHADOW_SRC.obj &&
   mkdir -p $SHADOW_SRC.obj &&
   cd $SHADOW_SRC.obj &&
   ../$SHADOW_SRC.copy/configure --prefix="$SYS_ROOT" \
      --build=${HOST} \
      --host=${TARGET} \
      --cache-file=config.cache \
      --enable-subordinate-ids=no \
      --disable-dependency-tracking \
      --without-libbsd &&
   echo "#define ENABLE_SUBIDS 1" >> config.h &&
   make -j$PROCS && make exec_prefix=$SYS_ROOT -j$PROCS install && cd ..
}

install_sed() {
   mkdir -p $SED_SRC.obj &&
   cd $SED_SRC.obj &&
   $SOURCE/$SED_SRC/configure --prefix="$SYS_ROOT" \
      --build="$HOST" \
      --host="$TARGET" &&
   make -j$PROCS &&
   make -j$PROCS install &&
   cd ..
}

install_gmp() {
  rm -rf $GMP_SRC.obj &&
  mkdir -p $GMP_SRC.obj &&
  cd $GMP_SRC.obj &&
  CC_FOR_BUILD="$HOST_MACHINE-gcc" $SOURCE/$GMP_SRC/configure \
      --prefix="$SYS_ROOT" \
      --build=${HOST} \
      --host=${TARGET} &&
  make -j$PROCS &&
  make -j$PROCS install &&
  cd ..
}

install_mpfr() {
   rm -rf $MPFR_SRC.obj &&
   mkdir -p $MPFR_SRC.obj &&
   cd $MPFR_SRC.obj &&
   $SOURCE/$MPFR_SRC/configure --prefix="$SYS_ROOT" \
      --build=${HOST} \
      --host=${TARGET} &&
   make -j$PROCS &&
   make -j$PROCS install &&
   cd ..
}

install_mpc() {
   rm -rf $MPC_SRC.obj &&
   mkdir -p $MPC_SRC.obj &&
   cd $MPC_SRC.obj &&
   $SOURCE/$MPC_SRC/configure --prefix="$SYS_ROOT" \
      --build=${HOST} \
      --host=${TARGET} &&
   make -j$PROCS &&
   make -j$PROCS install &&
   cd ..
}

install_gcc() {
   print_info "Compiling GCC"
   cp -R $SOURCE/$GCC_SRC $GCC_SRC.compiler
   cd $GCC_SRC.compiler &&
   cp -v gcc/Makefile.in{,.orig} &&
   sed 's@\./fixinc\.sh@-c true@' gcc/Makefile.in.orig > gcc/Makefile.in &&
   cd .. &&
   rm -rf $GCC_SRC.obj &&
   mkdir -p $GCC_SRC.obj &&
   cd $GCC_SRC.obj &&
   LDFLAGS="-lpthread" \
   ../$GCC_SRC.compiler/configure \
      --prefix=$SYS_ROOT \
      --build=${HOST} \
      --target=${TARGET} \
      --host=${TARGET} \
      --disable-multilib \
      --disable-bootstrap \
      --with-local-prefix="$SYS_ROOT" \
      --disable-nls \
      --enable-languages=c,c++ \
      --disable-libstdcxx-pch \
      --with-system-zlib \
      --with-native-system-header-dir="$SYS_ROOT/include" \
      --enable-checking=release \
      --disable-libcilkrts \
      --disable-libssp
   cp -v Makefile{,.orig} &&
   sed "/^HOST_\(GMP\|ISL\|CLOOG\)\(LIBS\|INC\)/s:$SYS_ROOT:$CROSS_TOOLS:g" \
         Makefile.orig > Makefile
   make -j$PROCS AS_FOR_TARGET="$AS" LD_FOR_TARGET="$LD" all &&
   make -j$PROCS install &&
   cd ..
}

install_ncurses () {
   rm -rf $NCURSES_SRC.obj &&
   mkdir -p $NCURSES_SRC.obj &&
   pushd $NCURSES_SRC.obj &&
   # Build required host tools.
   mkdir host &&
   pushd host &&
   CC=gcc RANLIB=ranlib AR=ar LD=ld PATH=/usr/bin \
      $SOURCE/$NCURSES_SRC/configure &&
   make -j$PROCS -C include &&
   make -j$PROCS -C progs tic &&
   popd &&
   LDFLAGS="-lpthread" CPPFLAGS="-P" $SOURCE/$NCURSES_SRC/configure \
     --prefix="${SYS_ROOT}" \
     --with-shared \
     --build=${HOST} \
     --host=${TARGET} \
     --without-debug \
     --without-ada \
     --with-termlib \
     --enable-overwrite \
     --with-build-cc=gcc &&
  make -j$PROCS &&
  make -j$PROCS TIC_PATH=$PWD/host/progs/tic install &&
  popd
}

install_vim () {
  rm -rf $VIM_SRC.obj &&
  cp -R $SOURCE/vim$VIM_BASE_VERSION $VIM_SRC.obj &&
  pushd $VIM_SRC.obj &&
  cat > src/auto/config.cache << "EOF"
  vim_cv_getcwd_broken=no
  vim_cv_memmove_handles_overlap=yes
  vim_cv_stat_ignores_slash=no
  vim_cv_terminfo=yes
  vim_cv_toupper_broken=no
  vim_cv_tty_group=world
  vim_cv_tgetent=zero
EOF
  ./configure --build=${HOST} \
    --host=${TARGET} \
    --prefix=${SYS_ROOT} \
    --enable-gui=no \
    --disable-gtktest \
    --disable-xim \
    --disable-gpm \
    --without-x \
    --disable-netbeans \
    --with-tlib=tinfo &&
  make -j$PROCS &&
  make -j$PROCS uninstall &&
  make -j$PROCS install &&
  ln -sfv vim $SYS_ROOT/bin/vi &&
  popd &&
  cat > $SYS_ROOT/etc/vimrc << "EOF"
set nocompatible
set backspace=2
set expandtab
set ts=2
set ruler
syntax on
EOF
}

install_make() {
   rm -rf $MAKE_SRC.obj &&
   mkdir -p $MAKE_SRC.obj &&
   cd $MAKE_SRC.obj &&
   $SOURCE/$MAKE_SRC/configure --prefix="$SYS_ROOT" \
      --build="$HOST" \
      --host="$TARGET" &&
   make -j$PROCS &&
   make -j$PROCS install &&
   cd ..
}

install_grep() {
   rm -rf $GREP_SRC.obj &&
   mkdir -p $GREP_SRC.obj &&
   cd $GREP_SRC.obj &&
   $SOURCE/$GREP_SRC/configure --prefix="$SYS_ROOT" \
      --build="$HOST" \
      --host="$TARGET" &&
   make -j$PROCS &&
   make install &&
   cd ..
}

install_gawk() {
   rm -rf $GAWK_SRC.obj &&
   mkdir -p $GAWK_SRC.obj &&
   cd $GAWK_SRC.obj &&
   $SOURCE/$GAWK_SRC/configure --prefix="$SYS_ROOT" \
      --build="$HOST" \
      --host="$TARGET" &&
   make -j$PROCS &&
   make install &&
   cd ..
}

generate_meson_cross_file () {
   local cross_file="$1"
   rm -f $cross_file &&
   local cpu_family
   if [ "$CPU" = "i686" ]; then
      cpu_family="x86"
   else
      cpu_family="x86_64"
   fi
   cat <<EOF > $cross_file
[built-in options]
default_library = 'both'

[paths]
prefix = '$SYS_ROOT'

[host_machine]
system = 'gnu'
cpu_family = '$cpu_family'
cpu = '$CPU'
endian = 'little'

[binaries]
c = '$CROSS_TOOLS/bin/$CPU-gnu-gcc'
cpp = '$CROSS_TOOLS/bin/$CPU-gnu-cpp'
ar = '$CROSS_TOOLS/bin/$CPU-gnu-ar'
ld = '$CROSS_TOOLS/bin/$CPU-gnu-ld'
strip = '$CROSS_TOOLS/bin/$CPU-strip'
pkg-config = '$CROSS_TOOLS/bin/pkg-config'
EOF
}

install_libpciaccess () {
   rm -rf $LIBPCIACCESS_SRC.obj &&
   mkdir -p $LIBPCIACCESS_SRC.obj &&
   local build_dir=$PWD/$LIBPCIACCESS_SRC.obj &&
   pushd $SOURCE/$LIBPCIACCESS_SRC &&
   generate_meson_cross_file cross-file-$CPU.txt &&
   meson setup --cross-file cross-file-$CPU.txt $build_dir &&
   meson compile -C $build_dir &&
   meson install -C $build_dir &&
   popd
}

install_libacpica () {
   rm -rf libacpica.obj &&
   mkdir -p libacpica.obj &&
   pushd libacpica.obj &&
   mkdir -p src &&
   cp -R $SOURCE/libacpica/* src/ &&
   pushd src &&
   (for patch in `ls debian/patches/*.diff`; do
      print_info "Patch $patch"
      patch -p1 < $patch
   done) &&
   make -j$PROCS &&
   make PREFIX=$SYS_ROOT install &&
   popd &&
   popd
}

install_rump () {
   local arch=""
   if [ $CPU = "i686" ]; then
      arch="i386"
   else
      arch="amd64"
   fi
   pushd $SOURCE/rumpkernel/ &&
      OBJ=`pwd`/obj
      mkdir -p $OBJ &&
      echo "OBJ $OBJ" &&
      git clean -fdx &&
      git checkout . &&
      for file in `cat debian/patches/series`; do
         echo $file
         patch -p1 < debian/patches/$file
      done
      pushd buildrump.sh/src &&
         pushd lib/librumpuser &&
            ./configure --prefix=$SYS_ROOT \
               --build=$HOST \
               --host=$TARGET &&
         popd &&
         CFLAGS="-Wno-format-security -Wno-omit-frame-pointer" \
         HOST_GCC=$HOST_CC TARGET_CC=$CC TARGET_CXX=$CC \
            TARGET_LD=$LD TARGET_MIG=$MIG \
            TARGET_LDADD="-B/$SYS_ROOT/lib -L$SYS_ROOT/lib -L$SYS_ROOT/lib" \
            _GCC_CRTENDS= _GCC_CRTEND= _CC_CRTBEGINS= \
            _GCC_CRTBEGIN= _GCC_CRTI= _GCC_CRTN= \
            BSDOBJECTDIR=$OBJ \
            ./build.sh \
               -V TOOLS_BUILDRUMP=yes \
               -V MKBINUTILS=no -V MKGDB=no -V MKGROFF=no \
               -V MKDTRACE=no -V MKZFS=no \
               -V TOPRUMP=$SOURCE/rumpkernel/buildrump.sh/src/sys/rump \
               -V BUILDRUMP_CPPFLAGS="-Wno-error=stringop-overread" \
               -V RUMPUSER_EXTERNAL_DPLIBS=pthread \
               -V CPPFLAGS="-I$OBJ/destdir/usr/include -D_FILE_OFFSET_BITS=64 -DRUMP_REGISTER_T=int -DRUMPUSER_CONFIG=yes -DNO_PCI_MSI_MSIX=yes -DNUSB_DMA=1 -DPAE" \
               -V CWARNFLAGS="-Wno-error=maybe-uninitialized -Wno-error=address-of-packed-member -Wno-error=unused-variable -Wno-error=stack-protector -Wno-error=array-parameter -Wno-error=array-bounds -Wno-error=stringop-overflow -Wno-error=int-to-pointer-cast -Wno-error=incompatible-pointer-types" \
               -V LIBCRTBEGIN=" " -V LIBCRTEND=" " -V LIBCRT0=" " -V LIBCRTI=" " \
               -V MIG=mig \
               -V DESTDIR=$OBJ/destdir \
               -V _GCC_CRTENDS=" " -V _GCC_CRTEND=" " \
               -V _GCC_CRTBEGINS=" " -V _GCC_CRTBEGIN=" " \
               -V _GCC_CRTI=" " -V _GCC_CRTN=" " \
               -V TARGET_LDADD="-B$SYS_ROOT/lib -L$SYS_ROOT/lib -L$SYS_ROOT/lib" \
               -U -u -T $OBJ/tooldir -m $arch -j $PROCS tools rump &&
         pushd lib/librumpuser &&
            RUMPRUN=true $OBJ/tooldir/bin/nbmake-$arch dependall
         popd &&
      popd &&
      pushd pci-userspace/src-gnu &&
         $OBJ/tooldir/bin/nbmake-$arch MIG=$MIG dependall &&
      popd &&
      # Perform installation by copying the required files.
      # Copy headers.
      cp -aR buildrump.sh/src/sys/rump/include/rump $SYS_ROOT/include/ &&
      # Copy libraries.
      find $OBJ/destdir buildrump.sh/src -type f,l \
         -name "librump*.so*" -not -path '*.map' -not -path '*librumpkern_z*' -exec cp -a {} $SYS_ROOT/lib/ \; &&
      find $OBJ/destdir buildrump.sh/src -type f,l \
         -name "librump*.a" -not -path '*librumpkern_z*' -exec cp -a {} $SYS_ROOT/lib \; &&
   popd
}

install_findutils () {
   rm -rf $LIBPCIACCESS_SRC.obj &&
   mkdir -p $LIBPCIACCESS_SRC.obj &&
   pushd $LIBPCIACCESS_SRC.obj &&
   $SOURCE/$FINDUTILS_SRC/configure --prefix=$SYS_ROOT \
      --build="$HOST" \
      --host="$TARGET" &&
   make -j$PROCS &&
   make -j$PROCS install &&
   popd
}

install_minimal_system() {
   install_libxcrypt &&
   install_libpciaccess &&
   install_libacpica &&
   install_zlib &&
   install_bzip2 &&
   install_gnumach &&
   install_gpg_error &&
   install_gcrypt &&
   install_ncurses &&
   install_util_linux &&
   install_rump &&
   # We need to build basic hurd libraries in order to
   # compile parted.
   install_hurd --without-parted &&
   install_dmidecode &&
   install_parted &&
   install_hurd &&
   install_bash &&
   install_dash &&
   install_coreutils &&
   install_e2fsprogs &&
   install_findutils &&
   install_grub &&
   install_shadow &&
   install_sed
}

install_more_shell_tools() {
   install_grep &&
   install_gawk
}

install_development_tools() {
   install_flex &&
   install_mig &&
   install_binutils &&
   install_gmp &&
   install_mpfr &&
   install_mpc &&
   install_gcc &&
   install_make
}

install_editors() {
   install_vim
}

mkdir -p $BUILD_ROOT/native &&
   cd $BUILD_ROOT/native &&
   install_minimal_system &&
   if [ $BUILD_TYPE = "full" ]; then
      install_more_shell_tools &&
      install_editors &&
      install_development_tools
   fi &&
   print_info "compile.sh finished successfully" &&
   exit 0
