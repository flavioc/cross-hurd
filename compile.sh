#!/bin/sh

. ./vars.sh
. ./download-funcs.sh
export CC="${TARGET}-gcc"
export CXX="${TARGET}-g++"
export AR="${ROOT}/bin/${TARGET}-ar"
export AS="${ROOT}/bin/${TARGET}-as"
export RANLIB="${ROOT}/bin/${TARGET}-ranlib"
export LD="${ROOT}/bin/${TARGET}-ld"
export STRIP="${ROOT}/bin/${TARGET}-strip"
export MIG="${ROOT}/bin/${TARGET}-mig"

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
   if [ -z "$USER32" ]; then
      disable_user32="--disable-user32"
   fi
   $SOURCE/$GNUMACH_SRC/configure \
      CFLAGS="-O2 -g" \
      --host="$TARGET" \
      --build="$HOST" \
      --exec-prefix=/tmp/throwitaway \
      --enable-kdb \
      --enable-kmsg \
      --enable-pae \
      --prefix="$SYS_ROOT" \
      $disable_user32 &&
   make -j$PROCS gnumach.gz gnumach gnumach.msgids &&
   make -j$PROCS install &&
   mkdir -p $SYSTEM/boot &&
   cp gnumach.gz $SYSTEM/boot/ &&
   cd -
}

install_hurd() {
   print_info "Compiling Hurd servers..."
   cd $SOURCE/$HURD_SRC &&
   autoreconf -i &&
   cd - &&
   mkdir -p $HURD_SRC.obj &&
   cd $HURD_SRC.obj &&
   $SOURCE/$HURD_SRC/configure \
      --build="$HOST" \
      --host="$TARGET" \
      --prefix="$SYS_ROOT" \
      --without-parted \
      --disable-profile &&
   make -j$PROCS all &&
   fakeroot make -j$PROCS install &&
   cd ..
}

install_binutils ()
{
   print_info "Compiling binutils"
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
   rm -rf $BASH.obj &&
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

install_shadow () {
   cp -R $SOURCE/$SHADOW_SRC $SHADOW_SRC.copy &&
   cd $SHADOW_SRC.copy &&
   cp -v src/Makefile.in src/Makefile.in.orig &&
   sed -e 's/groups$(EXEEXT) //' \
       -e 's/= nologin$(EXEEXT)/= /' \
       -e 's/= login$(EXEEXT)/= /' \
       -e 's/\(^suidu*bins = \).*/\1/' \
       -e 's/\(\t$(am__append_3) $(am__append_4)\)/#\1/' \
   src/Makefile.in.orig > src/Makefile.in &&
   cat > config.cache << "EOF"
shadow_cv_passwd_dir=$SYS_ROOT/bin
EOF
   cd - &&
   rm -rf $SHADOW_SRC.obj &&
   mkdir -p $SHADOW_SRC.obj &&
   cd $SHADOW_SRC.obj &&
   ../$SHADOW_SRC.copy/configure --prefix="$SYS_ROOT" \
      --build=${HOST} \
      --host=${TARGET} \
      --cache-file=config.cache \
      --enable-subordinate-ids=no \
      --disable-dependency-tracking &&
   echo "#define ENABLE_SUBIDS 1" >> config.h &&
   make -j$PROCS && make -j$PROCS install && cd ..
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
      --disable-libssp \
      --with-arch=$CPU &&
   cp -v Makefile{,.orig} &&
   sed "/^HOST_\(GMP\|ISL\|CLOOG\)\(LIBS\|INC\)/s:$SYS_ROOT:$ROOT:g" \
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
     --enable-overwrite \
     --with-build-cc=gcc &&
  make -j$PROCS &&
  make -j$PROCS TIC_PATH=$PWD/host/progs/tic install &&
  popd
}

install_vim () {
  # TODO: we should do this without messing up with the original code.
  cd $SOURCE/vim$VIM_BASE_VERSION &&
  cat > src/auto/config.cache << "EOF"
  vim_cv_getcwd_broken=no
  vim_cv_memmove_handles_overlap=yes
  vim_cv_stat_ignores_slash=no
  vim_cv_terminfo=yes
  vim_cv_toupper_broken=no
  vim_cv_tty_group=world
  vim_cv_tgetent=zero
EOF
  echo "#define SYS_VIMRC_FILE \"${SYS_ROOT}/etc/vimrc\"" >> src/feature.h
  ./configure --build=${HOST} \
    --host=${TARGET} \
    --prefix=${SYS_ROOT} \
    --enable-gui=no \
    --disable-gtktest \
    --disable-xim \
    --disable-gpm \
    --without-x \
    --disable-netbeans \
    --with-tlib=ncurses &&
  make -j$PROCS &&
  make -j$PROCS uninstall &&
  make -j$PROCS install &&
  ln -sfv vim $SYS_ROOT/bin/vi &&
  cd - &&
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

install_minimal_system() {
   install_zlib &&
   install_gnumach &&
   install_hurd &&
   install_bash &&
   install_coreutils &&
   install_util_linux &&
   install_e2fsprogs &&
   install_grub &&
   install_shadow &&
   install_sed
}

install_more_shell_tools() {
   install_grep &&
   install_gawk
}

install_development_tools() {
   install_gpg_error &&
   install_gcrypt &&
   install_flex &&
   install_mig &&
   install_binutils &&
   install_gmp &&
   install_mpfr &&
   install_mpc &&
   install_gcc &&
   install_make &&
   install_flex &&
   install_mig
}

install_editors() {
   install_ncurses &&
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
