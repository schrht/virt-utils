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

# Get image info
image_url=http://download.eng.pek2.redhat.com/pub/rhel-8/rel-eng/RHEL-8/RHEL-8.2.0-Beta-1.0/compose/BaseOS/x86_64/images/rhel-guest-image-8.2-128.x86_64.qcow2
image_file=$(basename $image_url)
image_label=$(echo $image_url | sed 's#^.*/\(.*\)/compose.*$#\1#')
image_repo_baseos=$(dirname $image_url | sed 's#/images$#/os#')
image_repo_appstream=$(echo $image_repo_baseos | sed 's#/BaseOS/#/AppStream/#')

# Download the image
if [ ! -e ${image_file}.origin ]; then
	wget $image_url && mv $image_file ${image_file}.origin || exit 1
fi

# Create workspace
#ws=./images/$image_label
ws=/var/lib/libvirt/images/$image_label
mkdir -p $ws

# Modify the image
sudo virsh list --all --name | grep -q -x $image_label
if [ "$?" = "0" ]; then
	echo -e "\nThe VM is already exist, skip modifying the image."
	echo -e "You can remove the VM and run this script again:"
	echo -e "sudo virsh shutdown $image_label"
	echo -e "sudo virsh destroy $image_label"
	echo -e "sudo virsh undefine $image_label"
	exit 1
fi

# Deliver image
echo -e "\nDelievering the image to $ws/$image_file ..."
sudo cp -i ${image_file}.origin $ws/$image_file

# Modify root password if specified
if [ ! -z "$ROOT_PASSWD" ]; then
	echo -e "Setting root password..."
	sudo virt-customize -a $ws/$image_file --root-password password:$ROOT_PASSWD
fi

# Set authorized key
echo -e "Setting authorized key..."
[ ! -e mycert.pub ] && ssh-keygen -t rsa -N "" -f mycert -q
sudo virt-customize -a $ws/$image_file --ssh-inject root:file:mycert.pub

# Setup dnf repo
echo -e "Setting up dnf repo..."
cp rhel.repo $ws/
sed -i "s#IMAGE_REPO_BASEOS#$image_repo_baseos#" $ws/rhel.repo
sed -i "s#IMAGE_REPO_APPSTREAM#$image_repo_appstream#" $ws/rhel.repo
sudo virt-customize -a $ws/$image_file --copy-in $ws/rhel.repo:/etc/yum.repos.d/

# Reset SELinux label
echo -e "Resetting SELinux label..."
sudo virt-customize -a $ws/$image_file --selinux-relabel

# Deploy VM
echo -e "\nDeploying the VM..."
cp template.xml $ws/template.xml
sed -i "s#INSTANCE_NAME#$image_label#" $ws/template.xml
sed -i "s#IMAGE_FILE#$ws/$image_file#" $ws/template.xml
sudo virsh define $ws/template.xml

# Start VM
echo -e "Starting the VM..."
sudo virsh start $image_label

# Get VM's IP ADDR
echo -e "Get VM's MAC ADDR..."
vm_mac=$(sudo virsh dumpxml RHEL-8.2.0-Beta-1.0 | grep "mac address=" | awk -F "'" '{print $2}')
for i in {1..5}; do
	echo -e "Get VM's IP ADDR, attempting $i..."
	sleep 10
	vm_ip=$(arp | grep $vm_mac | awk '{print $1}')
	[ ! -z "$vm_ip" ] && break
done
[ -z "$vm_ip" ] && echo -e "\nTimed out: failed to get VM's IP ADDR, exit." && exit 1

# Show VM connection
vm_ssh="ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ./mycert root@$vm_ip"
echo $vm_ssh

# Configure HA tests
scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ./mycert ha_commands.sh root@$vm_ip:/root/"
$vm_ssh "bash /root/ha_commands.sh"

$vm_ssh

exit 0

# Check essentials

if ! [[ $img =~ .qcow2$ ]]; then
	echo -e "ERROR: qcow2 image is expected."
	exit 1
fi

