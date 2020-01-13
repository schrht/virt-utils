#!/bin/bash

# Description:
#   Use this script to process image for cloud usage.
#
# Required packages:
#   - libguestfs-tools-c
#
# Inputs:
#   $1: [optional] The image URL to download.
#   $2: [optional] The workspace to use.
#
# Outputs:
#   1. This script will download some files under workspace.
#   2. export varibles for other scripts to use.
#
# History:
#   v1.0  2020-01-13  charles.shih  Init version

source ./config.txt

function download_image() {
	# Description:
	#   Parse image URL and download the image from internal file server.
	#
	# Inputs:
	#   $1: [optional] The image URL to download.
	#   $2: [optional] The workspace to use.
	#
	# Outputs:
	#   image_url
	#   image_file
	#   image_label
	#   repo_baseos
	#   repo_appstream
	#   workspace
	#
	# Others:
	#   This function will download some files under $workspace.

	# Get image URL
	if [ ! -z "$1" ]; then
		image_url=$1
	elif [ -z "$image_url" ]; then
		read -p "Enter image URL: " image_url
	fi

	# Ex. http://download.eng.pek2.redhat.com/pub/rhel-8/rel-eng/RHEL-8/RHEL-8.2.0-Beta-1.0/compose/BaseOS/x86_64/images/rhel-guest-image-8.2-128.x86_64.qcow2
	[[ ! $image_url =~ .qcow2$ ]] && echo -e "ERROR: a qcow2 image is expected." && return 1

	# Get image info
	image_file=$(basename $image_url)
	image_label=$(echo $image_url | sed 's#^.*/\(.*\)/compose.*$#\1#')
	repo_baseos=$(dirname $image_url | sed 's#/images$#/os#')
	repo_appstream=$(echo $repo_baseos | sed 's#/BaseOS/#/AppStream/#')
	workspace=${2:-"/var/lib/libvirt/images"}/$image_label

	# Let user confirm the information
	echo -e "\nPlease confirm the following information:"
	echo -e "IMAGE URL:           $image_url"
	echo -e "IMAGE LABEL:         $image_label"
	echo -e "IMAGE FILE NAME:     $image_file"
	echo -e "REPO URL(BASEOS):    $repo_baseos"
	echo -e "REPO URL(APPSTREAM): $repo_appstream"
	echo -e "WORKSPACE:           $workspace"
	echo -e "\nIf you need a correction, press <Ctrl+C> in 30 seconds... Or press <Enter> to continue immediately..."
	read -t 30

	# Download the image
	mkdir -p $workspace
	pushd $workspace >/dev/null || return 1

	if [ ! -e ${image_file}.origin ]; then
		wget $image_url
		wget ${image_url}.MD5SUM
		md5sum -c ${image_file}.MD5SUM || return 1
		cp $image_file ${image_file}.origin
	else
		cp -i ${image_file}.origin $image_file
	fi

	popd >/dev/null

	return 0
}

function process_image() {
	# Description:
	#   Process the image for general cloud usage.
	#
	# Inputs:
	#   workspace
	#   image_file
	#   repo_baseos
	#   repo_appstream
	#   ROOT_PASSWD: [optional] The new root password of the image
	#   PUBKEY_FILE: [optional] The public key file to be added into the image
	#
	# Outputs:
	#   n/a

	# Check varibles
	[ -z "$workspace" ] && echo "\$workspace cannot be empty." && return 1
	[ -z "$image_file" ] && echo "\$image_file cannot be empty." && return 1
	[ -z "$repo_baseos" ] && echo "\$repo_baseos cannot be empty." && return 1
	[ -z "$repo_appstream" ] && echo "\$repo_appstream cannot be empty." && return 1

	# Check utilities
	virt-customize -V >/dev/null || return 1

	# Modify root password if configured
	if [ ! -z "$ROOT_PASSWD" ]; then
		echo -e "Setting root password..."
		virt-customize -a $workspace/$image_file --root-password password:$ROOT_PASSWD
	fi

	# Set authorized key
	echo -e "Setting authorized key..."
	if [ ! -z "$PUBKEY_FILE" ] && [ -e $PUBKEY_FILE ]; then
		virt-customize -a $workspace/$image_file --ssh-inject root:file:$PUBKEY_FILE
	else
		[ ! -e mycert.pub ] && ssh-keygen -t rsa -N "" -f mycert -q
		virt-customize -a $workspace/$image_file --ssh-inject root:file:mycert.pub
	fi

	# Setup dnf repo
	echo -e "Setting up dnf repo..."
	cp rhel.repo $workspace/
	sed -i "s#IMAGE_REPO_BASEOS#$repo_baseos#" $workspace/rhel.repo
	sed -i "s#IMAGE_REPO_APPSTREAM#$repo_appstream#" $workspace/rhel.repo
	virt-customize -a $workspace/$image_file --copy-in $workspace/rhel.repo:/etc/yum.repos.d/

	# Reset SELinux label
	echo -e "Resetting SELinux label..."
	virt-customize -a $workspace/$image_file --selinux-relabel

	return 0
}

function start_vm() {
	# Description:
	#   Deploy and start VM with the image for advanced procedure.
	#
	# Inputs:
	#   workspace
	#   image_file
	#   image_label
	#
	# Outputs:
	#   n/a

	# Check varibles
	[ -z "$workspace" ] && echo "\$workspace cannot be empty." && return 1
	[ -z "$image_file" ] && echo "\$image_file cannot be empty." && return 1
	[ -z "$image_label" ] && echo "\$image_label cannot be empty." && return 1

	# Get sudo access
	sudo bash -c : || return 1

	# Check utilities
	sudo virsh --version >/dev/null || return 1

	# Check VM status
	sudo virsh list --all --name | grep -q -x $image_label
	if [ "$?" = "0" ]; then
		echo -e "\nThe VM already exists. You may want to run the following commands:"
		echo -e "sudo virsh shutdown $image_label"
		echo -e "sudo virsh undefine $image_label"
		return 1
	fi

	# Deploy VM
	echo -e "\nDeploying the VM..."
	cp template.xml $workspace/template.xml
	sed -i "s#INSTANCE_NAME#$image_label#" $workspace/template.xml
	sed -i "s#IMAGE_FILE#$workspace/$image_file#" $workspace/template.xml
	sudo virsh define $workspace/template.xml

	# Start VM
	echo -e "Starting the VM..."
	sudo virsh start $image_label

	# Get VM's IP ADDR
	echo -e "Get VM's MAC ADDR..."
	vm_mac=$(sudo virsh dumpxml $image_label | grep "mac address=" | awk -F "'" '{print $2}')
	for i in {1..5}; do
		echo -e "Get VM's IP ADDR, attempting $i..."
		sleep 10
		vm_ip=$(arp | grep $vm_mac | awk '{print $1}')
		[ ! -z "$vm_ip" ] && echo -e "\nIP ADDR = $vm_ip" && break
	done
	[ -z "$vm_ip" ] && echo -e "\nTimed out: failed to get VM's IP ADDR, exit." && return 1

	# Show connect information
	vm_ssh="ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ./mycert root@$vm_ip"
	echo -e "\nSSH command:"
	echo -e "$vm_ssh"
	echo -e "\nRun the following commands to remove the VM after using:"
	echo -e "sudo virsh shutdown $image_label"
	echo -e "sudo virsh undefine $image_label"

	return 0
}

function customize_ha_image() {
	# Description:
	#   Do additional customization for HA usage (after general processing).
	#
	# Inputs:
	#   workspace
	#   image_file
	#
	# Outputs:
	#   n/a

	# Check varibles
	[ -z "$workspace" ] && echo "\$workspace cannot be empty." && return 1
	[ -z "$image_file" ] && echo "\$image_file cannot be empty." && return 1

	# Check utilities
	virt-customize -V >/dev/null || return 1

	# Enlarge the image
	echo -e "Enlarge the image..."
	local fsize=$(ls -l $workspace/$image_file | awk '{print $5}')
	if [ "$fsize" -lt "$((20 * 1024 * 1024 * 1024))" ]; then
		qemu-img create -f qcow2 -o preallocation=metadata $workspace/newdisk.qcow2 20G || return 1
		virt-resize --expand /dev/sda1 $workspace/$image_file $workspace/newdisk.qcow2 || return 1
		mv -f $workspace/newdisk.qcow2 $workspace/$image_file || return 1
	fi

	# Install packages
	echo -e "Install packages..."
	for package in $(cat ./ha_packages.txt); do
		virt-customize -a $workspace/$image_file --install $package
	done

	# HA Customize
	#virt-customize -a $workspace/$image_file --commands-from-file ./ha_customize.txt

	# Reset SELinux label
	echo -e "Resetting SELinux label..."
	virt-customize -a $workspace/$image_file --selinux-relabel

	return 0
}
