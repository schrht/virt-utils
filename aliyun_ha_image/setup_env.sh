#!/bin/bash

packages="
libguestfs
libguestfs-tools-c
libvirt
libvirt-client
"

for name in $packages; do
	x=$(rpm -q $name 2>/dev/null)
	if [ "$?" = "0" ]; then
		echo "Package $name has been installed ($x)."
	else
		echo "Installing package $name ..." 
		sudo dnf install -y $name
	fi
done

exit 0

