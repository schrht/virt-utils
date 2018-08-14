#!/bin/bash

#set -e

die() { echo -e "$@"; exit 1; }

reboot_instance()
{
	ssh -i $pem $user@$instname "sudo reboot"
}

waiting_instance_online()
{
	# waiting ssh online
	unset ping_state
	while [ "$ping_state" != "OK" ] || [ "$ssh_state" != "OK" ]; do
		ping $instname -c 1 -W 2 &>/dev/null && ping_state="OK" || ping_state="FAIL"
		ssh -i $pem -o "ConnectTimeout 8" $user@$instname -t "echo" &>/dev/null && ssh_state="OK" || ssh_state="FAIL"
		echo -e "\nCurrent Time: $(date +"%Y-%m-%d %H:%M:%S") | PING State: $ping_state | SSH State: $ssh_state"
		sleep 2
	done
}


# Main
[ $# -lt 3 ] && die "\nUsage: $0 <pem file> <username> <hostname>\n"

pem=$1
user=$2
instname=$3

# Install ntpdate
ssh -i $pem $user@$instname "sudo yum install ntpdate -y"

# Disable ntp service
ssh -i $pem $user@$instname "sudo systemctl stop ntpd"
ssh -i $pem $user@$instname "sudo systemctl disable ntpd"
ssh -i $pem $user@$instname "sudo systemctl stop chronyd"
ssh -i $pem $user@$instname "sudo systemctl disable chronyd"
ssh -i $pem $user@$instname "sudo timedatectl set-ntp 0"

# NTP Query
ssh -i $pem $user@$instname "/usr/sbin/ntpdate -q de.ntp.org.cn > ~/ntp_query_reboot_0_$(date +%Y%m%d%H%M%S).log"

# Reboot the instance x times
for n in {1..10}; do
	echo -e "\nInstance reboot ($n):"

	# Reboot
	reboot_instance
	waiting_instance_online

	# NTP Query
	ssh -i $pem $user@$instname "/usr/sbin/ntpdate -q de.ntp.org.cn > ~/ntp_query_reboot_${n}_$(date +%Y%m%d%H%M%S).log"
done

exit 0

