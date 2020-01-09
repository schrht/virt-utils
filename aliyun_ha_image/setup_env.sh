#!/bin/bash

packages="
libguestfs
libguestfs-tools-c
libvirt
libvirt-client
"

for pack in $packages; do
	rpm -qa $pack || sudo dnf install -y $pack
done

exit 0

