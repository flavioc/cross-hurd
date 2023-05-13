#!/bin/bash
# Runs all known build configurations locally.

# Full i686 build.
CPU=i686 bash bootstrap.sh
CPU=i686 bash compile.sh

# Full x86_64 build.
CPU=x86_64 bash bootstrap.sh
CPU=x86_64 bash compile.sh

# x86_64 Gnumach on 32 bit userland.
CPU=x86_64 USER32=1 bash bootstrap-kernel.sh
