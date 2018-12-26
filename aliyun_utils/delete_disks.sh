#!/bin/bash

# Description:
# Delete specified disks from a region.
#
# Dependency:
# 1. aliyun-cli(3.0.6)
# 2. jq
#
# History:
# v1.0  2018-12-24  charles.shih  Init version

region=${1:-"cn-beijing"}
disk_name=${2:-"avocado_cloud_disk_d1"}

echo -e "\nLooking up disks named \"$disk_name\" from \"$region\"..."
x=$(aliyun ecs DescribeDisks --RegionId $region --DiskName $disk_name)
[ $? != 0 ] && echo $x && exit 1
disk_list=$(echo $x| jq -r '.Disks.Disk[].DiskId')
echo -e "Found $(echo $disk_list | wc -w) disks.\n"
[ -z "$disk_list" ] && exit 0

for disk_id in $disk_list; do
	echo -e "Deleting NIC $disk_id..."
	#aliyun ecs DeleteDisk --RegionId $region --DiskId $disk_id
	aliyun ecs DeleteDisk --DiskId $disk_id
done

echo -e "\nRun this script again to make sure the deletion is successful."

exit 0

