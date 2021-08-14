#!/bin/bash

rm -rfv tmp/bin/ tmp/boot/ tmp/cross-tools/ tmp/tools/ tmp/src/*.obj

# Delete extracted source folders
for dir in tmp/src/*; do
  if [ -d "$dir" ]; then
    if [ -d "$dir/.git" ]; then
      echo "Skip $dir"
    else
      rm -rf "$dir"
    fi
  fi
done

# Remove built image
rm -fv hd.img
