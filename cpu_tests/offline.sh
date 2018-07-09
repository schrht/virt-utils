#!/bin/bash

#dryrun=1

run() { echo -e "\n> $@" && [ -z $dryrun ] && eval $@; }

if [ -z $1 ]; then
	echo "Usage: $0 <cpuids>"
	echo "Example: $0 0..3,8,16,28..31"
	exit 1
fi

cpuid_str=$1

if [[ ! $cpuid_str =~ "," ]]; then
	cpuids="$cpuid_str"
else
	cpuids=""
	for id in $(eval echo {$cpuid_str}); do
		if [[ $id =~ ".." ]]; then
			cpuids="$cpuids $(eval echo {$id})"
		else
			cpuids="$cpuids $id"
		fi
	done
fi

echo -e "\nWill offline CPU #: $cpuids"

for cpuid in $cpuids; do
	file=/sys/devices/system/cpu/cpu${cpuid}/online
	if [ -e $file ]; then
		run "echo 0 > /sys/devices/system/cpu/cpu${cpuid}/online"
	else
		echo -e "\nNo such file: $file"
	fi
done

exit 0

