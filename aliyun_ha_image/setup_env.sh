#!/bin/bash

packages="
git
libguestfs
libguestfs-tools-c
libvirt
libvirt-client
"

# Install packages
for name in $packages; do
	x=$(rpm -q $name 2>/dev/null)
	if [ "$?" = "0" ]; then
		echo "Package $name has been installed ($x)."
	else
		echo "Installing package $name ..." 
		sudo dnf install -y $name
	fi
done

# Configure libvirt
[ ! -w /var/lib/libvirt/images/ ] && sudo chmod 777 /var/lib/libvirt/images/
sudo systemctl enable --now libvirtd

exit 0

