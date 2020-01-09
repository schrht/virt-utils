#!/bin/bash

# Description:
#   Use this script to deal create image for HA tests.
#
# Required packages:
#   - libguestfs-tools-c
#   
# History:
#   v0.1  2020-01-09  charles.shih  Init version

#if [ $# -lt 1 ]; then
#	echo "Usage: $0 <qcow2 image>"
#	exit 1
#fi

sudo bash -c : || exit 1

source ./config.txt

image_url=http://download.eng.pek2.redhat.com/pub/rhel-8/rel-eng/RHEL-8/RHEL-8.2.0-Beta-1.0/compose/BaseOS/x86_64/images/rhel-guest-image-8.2-128.x86_64.qcow2
image_file=$(basename $image_url)
image_label=$(echo $image_url | sed 's#^.*/\(.*\)/compose.*$#\1#')
image_repo_baseos=$(dirname $image_url | sed 's#/images$#/os#')
image_repo_appstream=$(dirname $image_url | sed 's#/BaseOS/#/AppStream/#')

if [ ! -e ${image_file}.origin ]; then
	wget $image_url && mv $image_file ${image_file}.origin || exit 1
fi

ws=/tmp/images/$image_label
mkdir -p $ws


if [ sudo virsh list | grep -q $image_lable ]; then
	echo -e "\nThe VM is already running, skip modifying the image."
	exit 1
fi

# Deploy image
sudo cp -i ${image_file}.origin $ws/$image_file

# Modify root password if specified
if [ ! -z "$ROOT_PASSWD" ]; then
	sudo virt-customize -a $ws/$image_file --root-password password:$ROOT_PASSWD
fi

# Add authorized_keys
[ ! -e mycert.pub ] && ssh-keygen -t rsa -N "" -f mycert -q
sudo virt-customize -a $ws/$image_file --ssh-inject root:file:mycert.pub
sudo virt-customize -a $ws/$image_file --selinux-relabel

# Deploy and start the VM
cp template.xml $ws/template.xml
sed -i "s#INSTANCE_NAME#$image_label#" $ws/template.xml
sed -i "s#IMAGE_FILE#$ws/$image_file#" $ws/template.xml
sudo virsh define $ws/template.xml
sudo virsh start $image_label

# Get VM's IP ADDR
echo -e "\nGet VM's MAC ADDR..."
vm_mac=$(sudo virsh dumpxml RHEL-8.2.0-Beta-1.0 | grep "mac address=" | awk -F "'" '{print $2}')
for i in {1..5}; do
	echo -e "\nGet VM's IP ADDR, attempting $1..."
	sleep 10
	vm_ip=$(arp | grep $vm_mac | awk '{print $1}')
	[ ! -z "$vm_ip" ] && break
done
[ -z "$vm_ip" ] && echo -e "\nFailed to get VM's IP ADDR, exit." && exit 1

# Login
ssh_opts="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"
ssh $ssh_opts -i ./mycert root@$vm_ip 

exit 0

# Check essentials

if ! [[ $img =~ .qcow2$ ]]; then
	echo -e "ERROR: qcow2 image is expected."
	exit 1
fi

