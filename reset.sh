#!/bin/sh

. ./vars.sh

if [ "$SYSTEM" = "/" ]; then
  exit 1
fi

echo "Removing from $SYSTEM..."

cd "$SYSTEM" &&
rm -rf bin boot tools cross-tools &&
rm -f /tools &&
rm -f /cross-tools
