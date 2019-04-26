#!/bin/bash

# Open and mount the container
label=`lsblk -o uuid,label | grep $1 | cut -d' ' -f2-`
mountpoint=$2-`date +%s%N`
sudo cryptsetup luksOpen /run/media/$USER/$label/$2 $mountpoint
sudo mkdir /mnt/$mountpoint
sudo mount /dev/mapper/$mountpoint /mnt/$mountpoint

#############################
## START OF BACKUP TARGETS ##
#############################

sudo -S rsync -ahvtu --delete --backup --backup-dir=rsync_file_history --suffix="."$(date +"%Y%m%d%H%M") \
     ~/.emacs.d \
     ~/Documents \
     /mnt/$mountpoint

sudo -S rsync -ahvtu --delete \
     ~/Music \
     ~/Pictures \
     /mnt/$mountpoint

###########################
## END OF BACKUP TARGETS ##
###########################

# Unmount and close the container
sudo umount /mnt/$mountpoint
sudo cryptsetup luksClose /dev/mapper/$mountpoint

# Safely remove the directory created for the mount point
if [[ $(sudo du -s /mnt/$mountpoint/) =~ ^[4\t] ]]; then
    sudo rmdir /mnt/$mountpoint
else
    echo ERROR: Could not safely remove /mnt/$mountpoint
fi

# Eject the drive
udisksctl unmount --block-device /dev/disk/by-uuid/$1
udisksctl power-off --block-device /dev/disk/by-uuid/$1

exit
