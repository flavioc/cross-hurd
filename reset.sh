#!/bin/sh

. ./vars.sh

if [ "$SYSTEM" = "/" ]; then
  exit 1
fi

echo "Removing from $SYSTEM..."

cd "$SYSTEM" &&
rm -rf bin boot tools cross-tools &&
echo "Removing /tools"
sudo rm -f /tools &&
echo "Removing /cross-tools"
sudo rm -f /cross-tools
rm -f hd.img
rm -rf src/*obj
