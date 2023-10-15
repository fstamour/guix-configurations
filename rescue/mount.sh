#!/bin/sh
#
# Mount the necessary filesystems to be able to chroot into "nu"
#
# Assumes /dev/nvme0n1p3 is already mounted at /mnt (because the
# script was saved on /mnt when I wrote it).
#

set -x
set -e

root=/dev/nvme0n1p3

efi=/dev/nvme0n1p1
swap=/dev/nvme0n1p2

mount $efi /mnt/boot/efi
swapon $swap

mount --rbind /proc /mnt/proc
mount --rbind /sys /mnt/sys
mount --rbind /dev /mnt/dev
