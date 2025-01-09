#!/bin/bash

. ./vars.sh

LOOP=$(sudo losetup -f)
LOOPPART="${LOOP}p1"
IMG=hd.img
IMG_SIZE=10GB
BASE_SYS_ROOT=$(basename $SYS_ROOT)

create_image() {
  print_info "Creating disk image $IMG using $LOOP..."
  fallocate -l $IMG_SIZE $IMG &&
    sudo losetup $LOOP $IMG &&
    sudo parted -a optimal -s $LOOP mklabel msdos &&
    sudo parted -a optimal -s $LOOP -- mkpart primary ext2 2048s -1 &&
    sudo parted -s $LOOP -- set 1 boot on &&
    sudo losetup -d $LOOP &&
    sudo losetup -P $LOOP $IMG &&
    sleep 2 &&
    # We need to ensure the partition devices exist. Inside a container,
    # these dynamic devices won't be created automatically.
    # https://github.com/moby/moby/issues/27886#issuecomment-417074845
    lsblk --raw --output "NAME,MAJ:MIN" --noheadings $LOOPDEV | tail -n +2 | while read dev node; do
      MAJ=$(echo $node | cut -d: -f1)
      MIN=$(echo $node | cut -d: -f2)
      [ ! -e "/dev/$dev" ] && mknod "/dev/$dev" b $MAJ $MIN
    done
  sudo mkfs.ext2 -o hurd -m 1 -v $LOOPPART
}

mount_image() {
  mkdir -p mount &&
    sudo mount -o rw -t ext2 $LOOPPART mount &&
    sudo chmod ogu+w -R mount/
}

copy_files() {
  print_info "Copying system into mount..."
  mkdir -p mount/{etc,boot,dev,usr,home,hurd,include,servers,lib,libexec,proc,sbin,bin,var,root,run,share} &&
    mkdir -p mount/var/{mail,run,lib,log} &&
    install -d -m700 mount/var/lib/sshd &&
    mkdir -p mount/servers/{socket,bus} &&
    cp -R files/etc/* mount/etc/ &&
    mkdir -p mount/etc/hurd &&
    cp files/runsystem.hurd mount/libexec/ &&
    chmod ogu+x mount/libexec/runsystem.hurd &&
    mkdir -p mount/boot/grub &&
    cp files/boot/grub.cfg mount/boot/grub/grub.cfg &&
    cp $SYSTEM/boot/gnumach.gz mount/boot &&
    mkdir -p mount/servers &&
    touch mount/servers/{acpi,exec,crash-kill,default-pager,password,socket,startup,proc,auth,symlink} &&
    mkdir mount/tmp && chmod 01777 mount/tmp &&
    cp -R $SYSTEM/$BASE_SYS_ROOT/hurd/* mount/hurd/ &&
    cp -R $SYSTEM/$BASE_SYS_ROOT/dev/* mount/dev/ &&
    cp -R $SYSTEM/$BASE_SYS_ROOT/include/* mount/include/ &&
    cp -R $SYSTEM/$BASE_SYS_ROOT/sbin/* mount/sbin/ &&
    cp -R $SYSTEM/$BASE_SYS_ROOT/bin/* mount/bin/ &&
    cp -R $SYSTEM/$BASE_SYS_ROOT/lib/* mount/lib/ &&
    cp -R $SYSTEM/$BASE_SYS_ROOT/share/* mount/share/ &&
    cp -R $SYSTEM/$BASE_SYS_ROOT/etc/* mount/etc/ &&
    cp -R $SYSTEM/$BASE_SYS_ROOT/libexec/* mount/libexec/ &&
    cp files/{rc,runsystem} mount/libexec/ &&
    (if [ -f mount/lib/ld-x86-64.so.1 ]; then
      ln -sfv /lib/ld-x86-64.so.1 mount/lib/ld.so
    else
      ln -sfv /lib/ld.so.1 mount/lib/ld.so
    fi) &&
    ln -svf / mount/$BASE_SYS_ROOT &&
    ln -svf /bin/bash mount/bin/sh &&
    cp files/SETUP mount/ &&
    chmod +x mount/SETUP &&
    rm -f manifest-$CPU.txt &&
    pushd mount &&
    (find . >../manifest-$CPU.txt || true) &&
    popd &&
    # Create a motd message.
    echo "Welcome to the HURD!" >mount/etc/motd &&
    echo "Cross-compiled from a $HOST on $(date)" >>mount/etc/motd &&
    # Ensure all files are owned by root inside the system image.
    sudo chown root:root -R mount/*
}

install_grub() {
  print_info "Installing the GRUB on $IMG..."
  sudo grub-install --target=i386-pc --directory=$SYS_ROOT/lib/grub/i386-pc --boot-directory=$PWD/mount/boot $LOOP
}

umount_image() {
  print_info "Umounting $LOOP"
  sudo umount mount >/dev/null 2>&1 &&
    sudo losetup -d $LOOP &&
    rmdir mount
}

qemu_arch() {
  if [ "$CPU" = "i686" ]; then
    echo "i386"
  else
    echo "x86_64"
  fi
}

qemu_net() {
  local network_hardware="nic,model=e1000"
  echo "-net user$(if [[ -f $SYS_ROOT/sbin/sshd ]]; then echo ",hostfwd=tcp:127.0.0.1:2222-:22"; fi) -net $network_hardware"
}

generate_ssh_host_keys() {
  if [[ -f files/etc/ssh/ssh_host_rsa_key ]]; then
    return 0
  fi
  mkdir -p files/etc/ssh &&
    print_info "Generating SSH host keys..." &&
    ssh-keygen -t rsa -f files/etc/ssh/ssh_host_rsa_key -N '' &&
    ssh-keygen -t ecdsa -f files/etc/ssh/ssh_host_ecdsa_key -N '' &&
    ssh-keygen -t ed25519 -f files/etc/ssh/ssh_host_ed25519_key -N ''
}

trap umount_image EXIT
trap umount_image INT

umount mount >/dev/null 2>&1
sudo losetup -d $LOOP >/dev/null 2>&1
rm -f $IMG
generate_ssh_host_keys &&
  create_image &&
  mount_image &&
  copy_files &&
  install_grub &&
  print_info "Disk image available on $IMG" &&
  print_info "Run the following command to boot the image:" &&
  echo "    qemu-system-$(qemu_arch) --enable-kvm -m 4G -drive cache=writeback,file=$IMG -M q35 $(qemu_net)" &&
  exit 0
