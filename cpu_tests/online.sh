#!/bin/bash

#dryrun=1

source ./func.sh

if [ -z $1 ]; then
	echo "Usage: $0 <cpuids>"
	echo "Example1: $0 0..3,8,10,12..15"
	echo "Example2: $0 0-3,8-11,16-19,24-27"
	exit 1
fi

cpuid_str=$1

cpuids=$(split $cpuid_str)

echo -e "\nWill Online CPU #: $cpuids"

for cpuid in $cpuids; do
	file=/sys/devices/system/cpu/cpu${cpuid}/online
	if [ -e $file ]; then
		run "echo 1 > /sys/devices/system/cpu/cpu${cpuid}/online"
	else
		echo -e "\nNo such file: $file"
	fi
done

exit 0

