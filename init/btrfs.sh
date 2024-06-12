#!/usr/bin/env -S bash -eux -o pipefail
#
# Small script to configure btrfs on "nu"
#

# NAME        MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
# sda           8:0    0 931.5G  0 disk
# └─sda1        8:1    0 931.5G  0 part
# sdb           8:16   0 931.5G  0 disk
# └─sdb1        8:17   0 931.5G  0 part
# sdc           8:32   0   1.8T  0 disk
# └─sdc1        8:33   0   1.8T  0 part

# 2 drives
mkfs.btrfs --metadata raid1 --data raid1  /dev/sd{a,b}1
# mount /dev/sda1 /home/fstamour/data

# 3 drives (this doesn't work well because they're not the same size)
# mkfs.btrfs --metadata raid1c3 --data raid1c3  /dev/sd{a,b,c}1
