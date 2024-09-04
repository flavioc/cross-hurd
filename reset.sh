#!/bin/sh

. ./vars.sh

if [ "$SYSTEM" = "/" ]; then
  exit 1
fi

echo "Removing from $SYSTEM..."

rm -rf build* &&
  rm -rf output* &&
  echo "Removing $SYS_ROOT"
sudo rm -f $SYS_ROOT &&
  echo "Removing $CROSS_TOOLS"
sudo rm -f $CROSS_TOOLS
echo "Removing $SYSTEM"
rm -rf $SYSTEM
rm -f hd.img
for dir in $(ls $SOURCE); do
  if [ -d $SOURCE/$dir ]; then
    if [ ! -d $SOURCE/$dir/.git ]; then
      echo "Removing $SOURCE/$dir"
      rm -rf $SOURCE/$dir
    fi
  fi
done
