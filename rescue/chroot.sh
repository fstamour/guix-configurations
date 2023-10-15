#!/bin/sh
#
# chroot into /mnt using a predefined script that sets up the
# environment appropriately.
#

set -x
set -e

chroot /mnt /root/chroot-command.sh
