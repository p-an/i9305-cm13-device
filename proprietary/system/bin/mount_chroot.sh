#!/system/bin/sh

CH=/system/cm12chroot

mount -obind /dev $CH/dev
mount -obind /efs $CH/efs
mount -obind /firmware $CH/firmware
mount -obind /tombstones $CH/tombstones
mount -obind /data $CH/data
mount sysfs -t sysfs $CH/sys
mount proc -t proc $CH/proc
