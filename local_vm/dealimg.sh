#!/bin/bash

# Description:
#   Use this script to deal with the guest image.
#
# Required packages:
#   - libguestfs-tools-c
#   
# History:
#   v1.0  2019-03-27  charles.shih  Init version
#   v1.1  2019-03-28  charles.shih  Support Fedora guest image

if [ $# -lt 1 ]; then
	echo "Usage: $0 <qcow2 image>"
	exit 1
fi

img=$1

# Check essentials

if ! [[ $img =~ .qcow2$ ]]; then
	echo -e "ERROR: qcow2 image is expected."
	exit 1
fi

virt-edit --version || exit 1
guestfish --version || exit 1

# Configure guest image

# a. Modify the guest image to enable root login
sudo virt-edit -a $img /etc/shadow -e 's/^root:[^:]*:/root::/'
 
# b. Using libguestfs tool to disable cloud-init service
sudo guestfish -a "$img" -i rm-rf '/etc/systemd/system/multi-user.target.wants/cloud-config.service'
sudo guestfish -a "$img" -i rm-rf  '/etc/systemd/system/multi-user.target.wants/cloud-final.service'
sudo guestfish -a "$img" -i rm-rf  '/etc/systemd/system/multi-user.target.wants/cloud-init-local.service'
sudo guestfish -a "$img" -i rm-rf '/etc/systemd/system/multi-user.target.wants/cloud-init.service'

sudo guestfish -a "$img" -i rm-rf '/etc/systemd/system/cloud-init.target.wants/cloud-config.service'
sudo guestfish -a "$img" -i rm-rf '/etc/systemd/system/cloud-init.target.wants/cloud-final.service'
sudo guestfish -a "$img" -i rm-rf '/etc/systemd/system/cloud-init.target.wants/cloud-init-local.service'
sudo guestfish -a "$img" -i rm-rf '/etc/systemd/system/cloud-init.target.wants/cloud-init.service'

exit 0

