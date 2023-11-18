#!/bin/bash

sudo rm -f /tools-{x86_64,i686} /cross-tools-{x86_64,i686}

rm -rfv output* build*

# Remove built image
rm -fv hd.img
