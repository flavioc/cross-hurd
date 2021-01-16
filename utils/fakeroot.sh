#!/bin/sh
# Execute a command in an environment where it appears to be root.
#
# Copyright (C) 2002, 2013 Free Software Foundation, Inc.
#
# This file is part of the GNU Hurd.
#
# The GNU Hurd is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 2, or (at
# your option) any later version.
#
# The GNU Hurd is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
#

USAGE="Usage: $0 [OPTION...] [COMMAND...]"
DOC="Execute COMMAND in an environment where it appears to be root."

while :; do
  case "$1" in
    --help|"-?")
      echo "$USAGE"
      echo "$DOC"
      echo ""
      echo "  -?, --help                 Give this help list"
      echo "      --usage                Give a short usage message"
      echo "  -V, --version              Print program version"
      exit 0;;
    --usage)
      echo "Usage: $0 [-V?] [--help] [--usage] [--version]"
      exit 0;;
    --version|-V)
      echo "STANDARD_HURD_VERSION_fakeroot_"; exit 0;;
    --)
      shift
      break;;
    -*)
      echo 1>&2 "$0: unrecognized option \`$1'"
      echo 1>&2 "Try \`$0 --help' or \`$0 --usage' for more information";
      exit 1;;
    *)
      break;;
  esac
done

if [ $# -eq 0 ]; then
  set -- ${SHELL:-/bin/sh}
fi

FAKED_MODE="unknown-is-root"
export FAKED_MODE

# We exec settrans, which execs the "fakeauth" command in the chroot
# context provided by /hurd/fakeroot.
exec /bin/settrans \
     --chroot-chdir "$PWD" \
     --chroot /bin/fakeauth "$@" -- \
     / /hurd/fakeroot
