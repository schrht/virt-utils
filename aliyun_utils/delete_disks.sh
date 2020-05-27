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
# v1.1  2018-12-26  charles.shih  Add PageSize to query full list
# v1.2  2020-05-26  charles.shih  Query 100 entries each time
# v2.0  2020-05-26  charles.shih  Support query all
# v2.1  2020-05-26  charles.shih  Delete disks in parallel

region=${1:-"cn-beijing"}
disk_name=${2:-"avocado_cloud_disk_d00"}

echo -e "\nLooking up disks named \"$disk_name\" from \"$region\"..."
if [ "$disk_name" != "all" ]; then
	x=$(aliyun ecs DescribeDisks --RegionId $region --DiskName $disk_name --PageSize 100)
else
	x=$(aliyun ecs DescribeDisks --RegionId $region --PageSize 100)
fi
[ $? != 0 ] && echo $x && exit 1
disk_list=$(echo $x| jq -r '.Disks.Disk[].DiskId')
echo -e "Found $(echo $disk_list | wc -w) disks.\n"
[ -z "$disk_list" ] && exit 0

for disk_id in $disk_list; do
	echo -e "Deleting disk $disk_id..."
	#aliyun ecs DeleteDisk --RegionId $region --DiskId $disk_id &
	aliyun ecs DeleteDisk --DiskId $disk_id &
done

wait

echo -e "\nRun this script again to make sure the deletion is successful."

exit 0

