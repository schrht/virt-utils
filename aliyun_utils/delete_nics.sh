#!/bin/bash

# Description:
# Delete specified NICs from a region.
#
# Dependency:
# 1. aliyun-cli(3.0.6)
# 2. jq
#
# History:
# v1.0    2018-12-24  charles.shih  Init version
# v1.1    2018-12-26  charles.shih  Add PageSize to query full list
# v1.1.1  2018-12-29  charles.shih  Fix a bug for checking $nic_list

region=${1:-"cn-beijing"}
nic_name=${2:-"avocado_cloud_nic_d00"}

echo -e "\nLooking up NICs named \"$nic_name\" from \"$region\"..."
if [ "$nic_name" != "all" ]; then
	x=$(aliyun ecs DescribeNetworkInterfaces --RegionId $region --NetworkInterfaceName $nic_name --PageSize 500)
else
	x=$(aliyun ecs DescribeNetworkInterfaces --RegionId $region --PageSize 500)
fi
[ $? != 0 ] && echo $x && exit 1
echo "Try to delete:"
echo $x | jq -r '.NetworkInterfaceSets.NetworkInterfaceSet[].NetworkInterfaceName' | sort | uniq -c
nic_list=$(echo $x | jq -r '.NetworkInterfaceSets.NetworkInterfaceSet[].NetworkInterfaceId')
echo -e "Found $(echo $nic_list | wc -w) NICs.\n"
[ -z "$nic_list" ] && exit 0

for nic_id in $nic_list; do
	echo -e "Deleting NIC $nic_id..."
	aliyun ecs DeleteNetworkInterface --RegionId $region --NetworkInterfaceId $nic_id
done

echo -e "\nRun this script again to make sure the deletion is successful."

exit 0

