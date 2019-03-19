#!/bin/bash

# Description: Used to test attach/detach NIC failure issues.
# History:
# v1.0.0  2019-03-19  charles.shih  Init version

public_ip=39.97.107.105
instance_id=i-2ze4970omnpkf3k2vj8e
disk_name=cheshi-nic-test

create_nic() {
	./aliyun ecs CreateNetworkInterface --VSwitchId vsw-2ze52osdol5jxuo96pv9f --SecurityGroupId sg-2zegq49eb2h96hflufnr --NetworkInterfaceName $disk_name | jq -r '.NetworkInterfaceId'
}

delete_nic() {
	./aliyun ecs DeleteNetworkInterface --NetworkInterfaceId $1
}

describe_nic() {
	./aliyun ecs DescribeNetworkInterfaces --NetworkInterfaceName $disk_name
}

attach_nic() {
	./aliyun ecs AttachNetworkInterface --NetworkInterfaceId $1 --InstanceId $2
}

detach_nic() {
	./aliyun ecs DetachNetworkInterface --NetworkInterfaceId $1 --InstanceId $2
}

check() {
	sleep 5s
	echo "=========="
	ping -c 1 $public_ip || exit 1
	echo "----------"
	ssh root@$public_ip ifconfig
	echo "----------"
	echo "Cloud disk named $disk_name:"
	x=$(./aliyun ecs DescribeNetworkInterfaces --NetworkInterfaceName $disk_name | jq -r '.NetworkInterfaceSets.NetworkInterfaceSet[].NetworkInterfaceId')
	echo $x
	if [ "$(echo $x | wc -w)" != "0" ] && [ "$(echo $x | wc -w)" != "2" ]; then
		echo "ERROR: The number should be 0 or 2."
		exit 1
	fi
	echo "=========="
}

test() {
	# create
	echo -e "\nCreate NICs..."
	nic_id1=$(create_nic)
	nic_id2=$(create_nic)
	check
	
	if [ -z $nic_id1 ] || [ -z $nic_id2 ]; then
		echo "ERROR: Create NIC failed."
		exit 1
	fi
	
	# attach
	echo -e "\nAttach NICs..."
	attach_nic $nic_id1 $instance_id
	attach_nic $nic_id2 $instance_id
	sleep 25s
	check
	
	# detach
	echo -e "\nDetach NICs..."
	detach_nic $nic_id1 $instance_id
	detach_nic $nic_id2 $instance_id
	sleep 25s
	check
	
	# delete
	echo -e "\nDelete NICs..."
	delete_nic $nic_id1
	delete_nic $nic_id2
	check
}

for i in {1..100}; do
	echo -e "\n** Round $i **"
	test
	sleep 5s
done

exit 0

