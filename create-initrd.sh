#!/bin/bash
#
if [ -z $CPU ]; then
   echo "CPU needs to be set"
   exit 1
fi

. ./vars.sh

LOOP=$(sudo losetup -f)
LOOPPART="${LOOP}p1"
IMG_SIZE=2048MB
BASE_SYS_ROOT=$(basename $SYS_ROOT)
INITRD_FILE=initrd.ext2
INITRD_SIZE=70MB
DISK_SIZE=2048MB
IMG=hd.img

create_initrd () {
   print_info "Creating disk image $INITRD_FILE using $LOOP..."
   fallocate -l $INITRD_SIZE $INITRD_FILE &&
      sudo losetup $LOOP $INITRD_FILE &&
      sudo mkfs.ext2 -o hurd -b 4096 -v $LOOP
      sudo losetup -d $LOOP &&
      sudo losetup -P $LOOP $INITRD_FILE &&
   sleep 2 &&
   fill_initrd
}

fill_initrd () {
   local src=$SYSTEM/$BASE_SYS_ROOT
   echo "Copying from $src"
   mkdir -p output-initrd &&
   sudo mount -o rw -t ext2 $LOOP output-initrd &&
   sudo chmod ogu+w -R output-initrd &&
   mkdir -p output-initrd/{dev,hurd,bin,lib,libexec,proc,sbin,servers} &&
   touch output-initrd/servers/{exec,crash-kill,default-pager,password,socket,startup,proc,auth,symlink} &&
   cp $src/hurd/{exec,auth,init,null,devnode,storeio,ext2fs,console,hello,streamio,proc,procfs,startup} output-initrd/hurd/ &&
   cp $src/lib/*.so* output-initrd/lib/ &&
   cp $src/bin/{settrans,echo,uname} output-initrd/bin/ &&
   cp $src/bin/dash output-initrd/bin/sh &&
   cp $src/bin/{ls,ps,settrans,cat,uptime,wall,who,yes,whoami,sleep,portinfo,msgport,fsysopts,env,sleep,date,tty,rpctrace,md5sum,cal,df,du} output-initrd/bin/ &&
   cp $src/sbin/{halt,reboot} output-initrd/sbin/ &&
   cp files/runsystem.initrd output-initrd/libexec/runsystem &&
   cp $src/bin/dash output-initrd/libexec/console-run &&
   ln -sf / output-initrd/tools-$CPU &&
   sudo mknod -m 600 output-initrd/dev/mach-console c 5 1 &&
   echo "Contents of initrd:" &&
   pushd output-initrd &&
   find .
   popd &&
   sudo losetup -d $LOOP
}

create_image () {
   print_info "Creating disk image $IMG using $LOOP..."
   fallocate -l $IMG_SIZE $IMG &&
      sudo losetup $LOOP $IMG &&
      sudo parted -a optimal -s $LOOP mklabel msdos &&
      sudo parted -a optimal -s $LOOP -- mkpart primary ext2 2048s -1 &&
      sudo parted -s $LOOP -- set 1 boot on &&
      sudo losetup -d $LOOP &&
      sudo losetup -P $LOOP $IMG &&
   sleep 2 &&
   sudo mkfs.ext2 -o hurd -m 1 -v $LOOPPART
}

mount_image () {
   mkdir -p output-disk &&
      sudo mount -o rw -t ext2 $LOOPPART output-disk &&
      sudo chmod ogu+w -R output-disk/
}

fill_disk () {
   local src=$SYSTEM/$BASE_SYS_ROOT
   mkdir -p output-disk/{sbin,boot,tools,lib} &&
   mkdir -p output-disk/boot/grub &&
   cp $src/hurd/ext2fs.static output-disk/sbin &&
   cp $src/lib/ld-x86-64.so.1 output-disk/lib/ld.so.1 &&
   mv $INITRD_FILE output-disk/boot &&
   cp $SYSTEM/boot/gnumach output-disk/boot &&
   cp files/boot/grub.initrd.cfg output-disk/boot/grub/grub.cfg &&
   echo "Disk contents:"
   pushd output-disk &&
   find .
   popd
}

install_grub () {
   print_info "Installing the GRUB on $IMG..."
   sudo grub-install --target=i386-pc --directory=$SYS_ROOT/lib/grub/i386-pc --boot-directory=output-disk/boot $LOOP
}

umount_initrd () {
   sudo umount output-initrd
   sudo losetup -d $LOOP
}

umount_image () {
   sudo umount output-disk >/dev/null 2>&1
   sudo losetup -d $LOOP >/dev/null 2>&1
}

trap umount_initrd EXIT
trap umount_initrd INT
trap umount_image EXIT
trap umount_image INT

rm -f $INITRD_FILE &&
rm -f $IMG &&
create_initrd &&
sudo umount output-initrd &&
echo $(losetup -f)
create_image &&
mount_image &&
fill_disk &&
install_grub &&
umount_image
