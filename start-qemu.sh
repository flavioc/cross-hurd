#!/bin/sh

qemu-system-x86_64 -s hd.img --enable-kvm -m 4096 -serial stdio
