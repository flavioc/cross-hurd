#!/bin/sh

. ./vars.sh

if [ "$SYSTEM" = "/" ]; then
  exit 1
fi

echo "Removing from $SYSTEM..."

cd "$SYSTEM" &&
rm -rf bin boot tools cross-tools &&
echo "Removing $SYS_ROOT"
sudo rm -f $SYS_ROOT &&
echo "Removing $ROOT"
sudo rm -f $ROOT
rm -f hd.img
for dir in `ls src`; do
  if [ -d src/$dir ]; then
    if [ ! -d src/$dir/.git ]; then
      echo "Removing src/$dir"
      rm -rf src/$dir
    fi
  fi
done
