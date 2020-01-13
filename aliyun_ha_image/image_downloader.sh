#!/bin/bash

# Description:
#   Use this script to download image from internal file server.
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

# Get image url
if [ ! -z "$1" ]; then
	image_url=$1
elif [ -z "$image_url" ]; then
	read -p "Enter image URL: " image_url
fi

# Ex. http://download.eng.pek2.redhat.com/pub/rhel-8/rel-eng/RHEL-8/RHEL-8.2.0-Beta-1.0/compose/BaseOS/x86_64/images/rhel-guest-image-8.2-128.x86_64.qcow2
[[ ! $image_url =~ .qcow2$ ]] && echo -e "ERROR: a qcow2 image is expected." && exit 1

# Get image info
image_file=$(basename $image_url)
image_label=$(echo $image_url | sed 's#^.*/\(.*\)/compose.*$#\1#')
repo_baseos=$(dirname $image_url | sed 's#/images$#/os#')
repo_appstream=$(echo $image_repo_baseos | sed 's#/BaseOS/#/AppStream/#')
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

# Go to workspace
mkdir -p $workspace && cd $workspace

# Download the image
if [ ! -e ${image_file}.origin ]; then
	wget $image_url
	wget ${image_url}.MD5SUM
	md5sum -c ${image_file}.MD5SUM || exit 1
	cp $image_file ${image_file}.origin
else
	cp ${image_file}.origin $image_file
fi

# Export varibles
export image_url
export image_file
export image_label
export repo_baseos
export repo_appstream
export workspace
