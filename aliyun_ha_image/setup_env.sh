#!/bin/bash

packages="
libguestfs
libguestfs-tools-c
libvirt
libvirt-client
"

for name in $packages; do
	x=$(rpm -qa $name 2>/dev/null)
	if [ "$?" = "0" ]; then
		echo "Package $name has been installed (${x})."
	else
		sudo dnf install -y $name
	fi
done

exit 0

