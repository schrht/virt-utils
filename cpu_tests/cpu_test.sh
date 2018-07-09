#!/bin/bash

#dryrun=1

run() { echo -e "\n> $@" && [ -z $dryrun ] && eval $@; }

frequence_boost() {

	label=${1:-"enable"}
	
	if [ "$label" = "enable" ]; then
		# Enable frequence boost (turbo mode)
		if [ -e /sys/devices/system/cpu/cpufreq/boost ]; then
			run "echo 1 > /sys/devices/system/cpu/cpufreq/boost"
		elif [ -e /sys/devices/system/cpu/intel_pstate/no_turbo ]; then
			run "echo 0 > /sys/devices/system/cpu/intel_pstate/no_turbo"
		else
			echo "Can not enable frequence boost."
		fi
	else
		# Disable frequence boost (turbo mode)
		if [ -e /sys/devices/system/cpu/cpufreq/boost ]; then
			run "echo 0 > /sys/devices/system/cpu/cpufreq/boost"
		elif [ -e /sys/devices/system/cpu/intel_pstate/no_turbo ]; then
			run "echo 1 > /sys/devices/system/cpu/intel_pstate/no_turbo"
		else
			echo "Can not disable frequence boost."
		fi
	fi
}


# Main

date

run "lscpu"

frequence_boost enable

# The On-line CPU must be shown in "A-B" format
start_num=$(lscpu | grep "On-line CPU(s) list:" | cut -d: -f2 | cut -d- -f1 | tr -d " ")

for i in {1..24}; do
	: ${start_num:=0}
	stop_num=$((start_num+i-1))
	run "turbostat --show Core,CPU,Avg_MHz,Busy%,Bzy_MHz,TSC_MHz,sysfs --quiet taskset -c ${start_num}-${stop_num} stress -c $i -t 10"
done

frequence_boost disable

run "turbostat --show Core,CPU,Avg_MHz,Busy%,Bzy_MHz,TSC_MHz,sysfs --quiet taskset -c ${start_num}-${stop_num} stress -c $i -t 10"

frequence_boost enable

exit 0

