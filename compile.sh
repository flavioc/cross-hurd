#!/bin/sh

. ./vars.sh
export CC="${ROOT}/bin/${TARGET}-gcc"
export CXX="${ROOT}/bin/${TARGET}-g++"
export AR="${ROOT}/bin/${TARGET}-ar"
export AS="${ROOT}/bin/${TARGET}-as"
export RANLIB="${ROOT}/bin/${TARGET}-ranlib"
export LD="${ROOT}/bin/${TARGET}-ld"
export STRIP="${ROOT}/bin/${TARGET}-strip"
export MIG="${ROOT}/bin/${TARGET}-mig"

install_flex() {
	cd "$FLEX_SRC" &&
	ac_cv_func_realloc_0_nonnull=yes ac_cv_func_malloc_0_nonnull=yes \
	./configure --prefix="$SYS_ROOT" \
		--build="$HOST" \
		--host="$TARGET" &&
	make all install &&
	cd ..
}

install_mig() {
   cd "$GNUMIG_SRC" &&
   autoreconf -i &&
   cd .. &&
   mkdir -p "$GNUMIG_SRC".obj &&
   cd "$GNUMIG_SRC".obj &&
   rm -f config.cache &&
   ../$GNUMIG_SRC/configure \
      --build="$HOST" \
      --host="$TARGET" \
      --prefix="$SYS_ROOT" \
      --target="$TARGET" &&
   make clean &&
   make -j$PROCS all install &&
   cd ..
}

install_zlib() {
   cd "$ZLIB_SRC" &&
./configure --prefix=$SYS_ROOT &&
make &&
make install &&
cd ..
}

install_gnumach() {
   cd "$GNUMACH_SRC" &&
   autoreconf -i &&
   cd .. &&
   rm -rf "$GNUMACH_SRC".obj &&
   mkdir -p "$GNUMACH_SRC".obj &&
   cd "$GNUMACH_SRC".obj &&
   ../$GNUMACH_SRC/configure \
	   --host="$TARGET" \
	   --build="$HOST" \
	   --exec-prefix= \
	   --enable-kdb \
	   --enable-kmsg \
	   --enable-pae \
	   --prefix="$SYS_ROOT" &&
   make -j$PROCS gnumach.gz gnumach gnumach.msgids install &&
   mkdir -p $SYSTEM/boot &&
   cp gnumach.gz $SYSTEM/boot/ &&
   cd -
}

install_hurd() {
   cd "$HURD_SRC" &&
   autoreconf -i &&
   cd .. &&
   rm -rf "$HURD_SRC".obj &&
   mkdir -p "$HURD_SRC".obj &&
   cd "$HURD_SRC".obj &&
   rm -f config.cache cnfig.status &&
   ../$HURD_SRC/configure \
      --build="$HOST" \
      --host="$TARGET" \
      --prefix="$SYS_ROOT" \
      --without-parted \
      --disable-profile &&
   make -j$PROCS all install &&
   cd ..
}

install_binutils ()
{
   print_info "Installing binutils"
   rm -rf "$BINUTILS_SRC".obj &&
   mkdir -p "$BINUTILS_SRC".obj &&
   cd "$BINUTILS_SRC".obj &&
   ../$BINUTILS_SRC/configure \
	--prefix="$SYS_ROOT" \
	--build="$HOST" \
	--host="$TARGET" \
	--target="$TARGET" \
	--with-lib-path="$SYS_ROOT"/lib \
	--disable-nls \
	--enable-shared \
	--disable-multilib &&
   make -j$PROCS all install &&
   cd ..
}

install_bash() {
	cd "$BASH_SRC" &&
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
./configure --prefix="$SYS_ROOT" \
    --build=${HOST} --host=${TARGET} \
    --without-bash-malloc --cache-file=config.cache &&
make && make install && cd ..
}

install_coreutils() {
	cd "$COREUTILS_SRC" &&
	cat > config.cache << EOF
fu_cv_sys_stat_statfs2_bsize=yes
gl_cv_func_working_mkstemp=yes
EOF
./configure --prefix="$SYS_ROOT" \
    --build=${HOST} --host=${TARGET} \
    --enable-install-program=hostname --cache-file=config.cache &&
make && make install && cd ..
}

install_libuuid() {
	cd "$LIBUUID_SRC" &&
	./configure --prefix="$SYS_ROOT" \
		--host="$HOST" \
		--target="$TARGET" &&
	make && make install &&
	cd ..
}

install_e2fsprogs() {
	cd "$E2FSPROGS_SRC" &&
	rm -rf build &&
	mkdir -vp build && cd build &&
	LDFLAGS="-luuid" ../configure --prefix="$SYS_ROOT" \
	    --enable-elf-shlibs --build=${HOST} --host=${TARGET} \
	    --disable-libblkid --disable-libuuid  \
	    --disable-uuidd &&
	LDFLAGS="-luuid" make && make install && make install-libs &&
	cd ..
}

install_util_linux() {
	cd "$UTIL_LINUX_SRC" &&
	./configure --prefix="$SYS_ROOT" \
	    --build="$HOST" --host="$TARGET" \
	    --disable-makeinstall-chown \
	    --disable-makeinstall-setuid  &&
	make &&
	make install &&
	cd ..
}

install_grub() {
	cd "$GRUB_SRC" &&
	cp -v grub-core/gnulib/stdio.in.h{,.orig} &&
	sed -e '/gets is a/d' grub-core/gnulib/stdio.in.h.orig > grub-core/gnulib/stdio.in.h &&
	./configure --prefix="$SYS_ROOT" \
	    --build=${HOST} --host=${TARGET} \
	    --disable-werror --enable-grub-mkfont=no --with-bootdir=tools/boot &&
	make &&
	make install &&
	cd ..
}

install_shadow () {
	cd "$SHADOW_SRC" &&
cp -v src/Makefile.in{,.orig} &&
sed -e 's/groups$(EXEEXT) //' \
    -e 's/= nologin$(EXEEXT)/= /' \
    -e 's/= login$(EXEEXT)/= /' \ # Hurd already provides it.
    -e 's/\(^suidu*bins = \).*/\1/' \
    src/Makefile.in.orig > src/Makefile.in &&
	cat > config.cache << "EOF"
shadow_cv_passwd_dir=/tools/bin
EOF
	./configure --prefix="$SYS_ROOT" \
    --build=${HOST} --host=${TARGET} --cache-file=config.cache \
	--enable-subordinate-ids=no &&
	echo "#define ENABLE_SUBIDS 1" >> config.h &&
	make && make install && cd ..
}

install_sed() {
	cd "$SED_SRC" &&
	./configure --prefix="$SYS_ROOT" \
		--build="$HOST" --host="$TARGET" &&
	make && make install && cd ..
}

cd "$SYSTEM"/src &&
install_zlib &&
install_flex &&
install_mig &&
install_gnumach &&
install_hurd &&
install_binutils &&
install_bash &&
install_coreutils &&
install_util_linux &&
install_e2fsprogs &&
install_grub &&
install_sed &&
install_shadow
