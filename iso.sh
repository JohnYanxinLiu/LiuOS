#!/bin/sh
set -e
. ./build.sh

mkdir -p isodir
mkdir -p isodir/boot
mkdir -p isodir/boot/grub

cp sysroot/boot/liuos.kernel isodir/boot/liuos.kernel
cat > isodir/boot/grub/grub.cfg << EOF
menuentry "liuos" {
	multiboot /boot/liuos.kernel
}
EOF
grub-mkrescue -o liuos.iso isodir
