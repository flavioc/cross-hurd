# Introduction

'cross-hurd' is a set of scripts for building a toolchain for cross-compiling the GNU Hurd operating system. The scripts will download the sources, compile all the packages required for building a cross-compiler and then compile a very basic operating system that is bootable using Qemu or other virtual machine.

It has been tested on Linux and does not appear to work on Mac OS X due to problems when building the Glibc.

# Downloading all the sources

The first step is to download all the required sources. Run the following to download all the required packages.

`$ bash download.sh`

The build system will use the most up-to-date gnumach, glibc, libpthread, mig and hurd packages by fetching them from the official git repositories available on http://git.savannah.gnu.org/cgit/hurd/.

# Building a toolchain

First, update the CC and CXX variables in **"vars.sh"** to match your architecture and GCC version.

Define CPU type **i686** or **x86_64**

To build the cross-compiler, run

`$ CPU=i686 bash bootstrap.sh`

The script will create a build environment on the $PWD/tmp directory. Two directory links, "/tools" and "/cross-tools" will be created: "/cross-tools" is a link to $PWD/tmp/cross-tools and contains the cross-compiler; "/tools" will contain the basic system and points to $PWD/tmp/tools. You will be asked for the root password for some steps in the process since we are creating links in the root file system.

Note that you need to install GCC, make, flex, bison, and other related packages in order to build the cross tools.

In Debian based distribution; you need to install the following packages:

`git sudo build-essential texinfo autopoint pkg-config libtool autotools-dev automake autoconf gettext libgmp-dev libmpfr-dev libmpc-dev zlib1g-dev flex bison gawk`

You may also need to additional path:

`$ export PATH=$PATH:/usr/sbin/:/sbin/`

# Compiling the basic system

Once the toolchain is in place, run the following to build a very basic set of packages using the cross-compiler built on the previous phase.

`$ CPU=i686 bash compile.sh`

Everything will be installed in $PWD/tmp/tools.

# Creating a bootable disk image

If everything went alright, then run the following to create a bootable disk image.

`$ CPU=i686 bash create-image.sh`

You will be asked for a sudo password because you need access to the loopback device. The script will use the base system built previously. The script runs **'grub-install'** on the final disk image and needs to have the files for the i386-pc architecture (If you use EFI boot in Debian, you need to install **grub-pc-bin**.). You may also use "create-initrd.sh" to build initrd image.

Once the file "hd.img" is in place, just run it on your favorite virtual machine. The grub bootloader will load GNU Mach and the Hurd and complete the installation process by populating the /dev directory and then rebooting. Afterwards, just enter "login root" to log into the system.

# Qemu specific parameters
In files/boot/grub.cfg, device type defined as "noide". Therefore, in qemu you need to add machine type Standard PC (Q35 + ICH9, 2009) by appending "-M q35". Example:

`$ qemu-system-i386 -m 2G -drive cache=writeback,file=hd.img -M q35`

But in case of image created with "create-initrd.sh", you don't need to append "-M q35".
