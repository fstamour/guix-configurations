#!/bin/sh
#
# This script is meant to be called by chroot, it sources a few
# profiles, starts a guix-daemon, cd to where I keep my config and
# starts bash.
#

set -x
set -e

user=fstamour

. /var/guix/profiles/system/profile/etc/profile
. /home/$user/.guix-profile/etc/profile
. /home/$user/.config/guix/current/etc/profile

guix-daemon --build-users-group=guixbuild --disable-chroot &

cd /home/$user/dev/guix-configurations/rescue

exec bash
