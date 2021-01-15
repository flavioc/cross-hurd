#!/bin/bash

. ./vars.sh

LOOP=/dev/loop0
MAPPER=/dev/mapper/loop0p1
IMG=hd.img
IMG_SIZE=2048MB

create_image () {
   print_info "Creating disk image $IMG..."
   fallocate -l $IMG_SIZE $IMG &&
      losetup $LOOP $IMG &&
      parted -a optimal -s $LOOP mklabel msdos &&
      parted -a optimal -s $LOOP -- mkpart primary ext2 32k -1 &&
      parted -s $LOOP -- set 1 boot on &&
      kpartx -a -v $LOOP && 
   sleep 2 &&
      mkfs.ext2 -o hurd -m 1 -v $MAPPER
}

mount_image () {
   mkdir -p mount &&
      mount -t ext2 $MAPPER mount
}

copy_files () {
   print_info "Copying system into mount..."
   cp -R tmp/tools mount/ &&
      mkdir -p mount/{etc,boot,dev,usr,hurd,servers,libexec,proc,sbin,bin,var,root} &&
      mkdir -p mount/var/run &&
      cp -R mount/tools/etc/* mount/etc/ &&
      mkdir -p mount/servers/socket &&
      cp -R files/etc/* mount/etc/ &&
      mkdir -p mount/etc/hurd &&
      cp files/runsystem.hurd mount/libexec/ &&
      chmod ogu+x mount/libexec/runsystem.hurd &&
      mkdir -p mount/tools/boot/grub &&
      cp files/boot/grub.cfg mount/tools/boot/grub &&
      cp files/boot/servers.boot mount/tools/boot &&
      cp tmp/boot/gnumach.gz mount/tools/boot &&
      mkdir -p mount/tools/servers &&
      touch mount/servers/{exec,crash-kill,default-pager,password,socket,startup,proc,auth,symlink} &&
      touch mount/tools/servers/{exec,crash-kill,default-pager,password,socket,startup,proc,auth,symlink} &&
      mkdir mount/tmp && chmod 01777 mount/tmp &&
      cp tmp/tools/hurd/* mount/hurd/ &&
      cp tmp/tools/sbin/* mount/sbin/ &&
      cp tmp/tools/bin/* mount/bin/ &&
      cp tmp/tools/libexec/{getty,runttys,console-run} mount/libexec/ &&
      cp files/{rc,runsystem} mount/libexec/ &&
      ln -svf /bin/bash mount/bin/sh &&
      ln -svf /tools/lib/ld-*.so mount/tools/lib/ld.so &&
      mv mount/tools/lib mount/lib &&
      ln -sf /lib mount/tools/lib &&
      cp files/SETUP mount/ &&
      chmod +x mount/SETUP &&
      # Create a motd message.
   echo "Welcome to the HURD!" > mount/etc/motd &&
      echo "Cross-compiled from a $HOST on `date`" >> mount/etc/motd
}

install_grub () {
   print_info "Installing the GRUB on $IMG..."
   grub-install --target=i386-pc --directory=/tools/lib/grub/i386-pc --boot-directory=$PWD/mount/tools/boot $LOOP
}

umount_image () {
   umount mount &&
      kpartx -d $LOOP &&
      losetup -d $LOOP &&
      rmdir mount
}

umount mount >/dev/null 2>&1
kpartx -d $LOOP >/dev/null 2>&1
losetup -d $LOOP >/dev/null 2>&1
rm -f $IMG
create_image &&
   mount_image &&
   copy_files &&
   install_grub &&
   umount_image &&
print_info "Disk image available on $IMG" &&
print_info "Run 'qemu $IMG' to enjoy the Hurd!" &&
exit 0
