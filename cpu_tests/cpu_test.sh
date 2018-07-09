#!/bin/bash

#dryrun=1

run() { echo -e "\n> $@" && [ -z $dryrun ] && eval $@; }

frequence_boost() {

	label=${1:-"enable"}
	
	if [ "$label" = "enable" ]; then
		# Enable frequence boost (turbo mode)
		if [ -e /sys/devices/system/cpu/cpufreq/boost ]; then
			cmd="echo 1 > /sys/devices/system/cpu/cpufreq/boost"
			run $cmd
		elif [ -e /sys/devices/system/cpu/intel_pstate/no_turbo ]; then
			cmd="echo 0 > /sys/devices/system/cpu/intel_pstate/no_turbo"
			run $cmd
		else
			echo "Can not enable frequence boost."
		fi
	else
		# Disable frequence boost (turbo mode)
		if [ -e /sys/devices/system/cpu/cpufreq/boost ]; then
			cmd="echo 0 > /sys/devices/system/cpu/cpufreq/boost"
			run $cmd
		elif [ -e /sys/devices/system/cpu/intel_pstate/no_turbo ]; then
			cmd="echo 1 > /sys/devices/system/cpu/intel_pstate/no_turbo"
			run $cmd
		else
			echo "Can not disable frequence boost."
		fi
	fi
}


# Main

date

cmd="lscpu"
run $cmd

frequence_boost enable

for i in {1,2,4,8,12,16,20,24}; do
	cmd="turbostat --show Core,CPU,Avg_MHz,Busy%,Bzy_MHz,TSC_MHz,sysfs --quiet taskset -c 0-$((i-1)) stress -c $i -t 10"
	run $cmd
done

frequence_boost disable

cmd="turbostat --show Core,CPU,Avg_MHz,Busy%,Bzy_MHz,TSC_MHz,sysfs --quiet taskset -c 0-$((i-1)) stress -c $i -t 10"
run $cmd

frequence_boost enable

exit 0

