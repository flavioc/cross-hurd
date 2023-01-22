#!/bin/bash

. ./vars.sh

LOOP=$(sudo losetup -f)
LOOPPART="${LOOP}p1"
IMG=hd.img
IMG_SIZE=2048MB
BASE_SYS_ROOT=$(basename $SYS_ROOT)

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
   mkdir -p mount &&
      sudo mount -o rw -t ext2 $LOOPPART mount &&
      sudo chmod ogu+w -R mount/
}

copy_files () {
   print_info "Copying system into mount..."
   cp -R tmp/$BASE_SYS_ROOT mount/ &&
      mkdir -p mount/{etc,boot,dev,usr,hurd,servers,libexec,proc,sbin,bin,var,root} &&
      mkdir -p mount/var/run &&
      cp -R mount/$BASE_SYS_ROOT/etc/* mount/etc/ &&
      mkdir -p mount/servers/socket &&
      cp -R files/etc/* mount/etc/ &&
      mkdir -p mount/etc/hurd &&
      cp files/runsystem.hurd mount/libexec/ &&
      chmod ogu+x mount/libexec/runsystem.hurd &&
      mkdir -p mount/$BASE_SYS_ROOT/boot/grub &&
      sed -e "s@/tools@$SYS_ROOT@g" files/boot/grub.cfg > mount/$BASE_SYS_ROOT/boot/grub/grub.cfg &&
      cp files/boot/servers.boot mount/$BASE_SYS_ROOT/boot &&
      cp tmp/boot/gnumach.gz mount/$BASE_SYS_ROOT/boot &&
      mkdir -p mount/$BASE_SYS_ROOT/servers &&
      touch mount/servers/{exec,crash-kill,default-pager,password,socket,startup,proc,auth,symlink} &&
      touch mount/$BASE_SYS_ROOT/servers/{exec,crash-kill,default-pager,password,socket,startup,proc,auth,symlink} &&
      mkdir mount/tmp && chmod 01777 mount/tmp &&
      cp tmp/$BASE_SYS_ROOT/hurd/* mount/hurd/ &&
      cp tmp/$BASE_SYS_ROOT/sbin/* mount/sbin/ &&
      cp tmp/$BASE_SYS_ROOT/bin/* mount/bin/ &&
      cp tmp/$BASE_SYS_ROOT/libexec/{getty,runttys,console-run} mount/libexec/ &&
      cp files/{rc,runsystem} mount/$BASE_SYS_ROOT/libexec/ &&
      ln -svf /bin/bash mount/bin/sh &&
      ln -svf $SYS_ROOT/lib/ld.so.1 mount/$BASE_SYS_ROOT/lib/ld.so &&
      mv mount/$BASE_SYS_ROOT/lib mount/lib &&
      ln -sf /lib mount/$BASE_SYS_ROOT/lib &&
      cp files/SETUP mount/ &&
      chmod +x mount/SETUP &&
      # Create a motd message.
   echo "Welcome to the HURD!" > mount/etc/motd &&
      echo "Cross-compiled from a $HOST on `date`" >> mount/etc/motd
}

install_grub () {
   print_info "Installing the GRUB on $IMG..."
   sudo grub-install --target=i386-pc --directory=$SYS_ROOT/lib/grub/i386-pc --boot-directory=$PWD/mount/$BASE_SYS_ROOT/boot $LOOP
}

umount_image () {
   print_info "Umounting $LOOP"
   sudo umount mount >/dev/null 2>&1 &&
      sudo losetup -d $LOOP &&
      rmdir mount
}

trap umount_image EXIT
trap umount_image INT

umount mount >/dev/null 2>&1
sudo losetup -d $LOOP >/dev/null 2>&1
rm -f $IMG
create_image &&
   mount_image &&
   copy_files &&
   install_grub &&
print_info "Disk image available on $IMG" &&
print_info "Run 'qemu-system-i386 $IMG' to enjoy the Hurd!" &&
exit 0
