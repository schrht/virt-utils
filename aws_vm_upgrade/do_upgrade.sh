#!/bin/bash

# clean the cache
yum clean all --disablerepo=* --enablerepo=rhel-debug || die "[FAILED] yum clean failed due to error."

# do upgrade
sudo yum update -y || die "[FAILED] yum update failed due to error."

# install specific packages
sudo yum install -y kernel-tools
sudo yum install -y kernel-devel
sudo yum install -y gcc
sudo yum install -y pciutils nvme-cli
sudo yum install -y wget
sudo yum install -y virt-what
sudo yum install -y libaio-devel
sudo yum install -y cryptsetup lvm2

# do some check
result="succeed"
echo "Check installed packages:"
rpm -q kernel-tools 	|| result="failed"
rpm -q kernel-devel 	|| result="failed"
rpm -q gcc 		|| result="failed"
rpm -q pciutils 	|| result="failed"
rpm -q nvme-cli 	|| result="failed"
rpm -q wget 		|| result="failed"
rpm -q virt-what 	|| result="failed"
rpm -q libaio-devel 	|| result="failed"
rpm -q cryptsetup	|| result="failed"
rpm -q lvm2		|| result="failed"

if [ "\$result" = "failed" ]; then
	echo -e "\nCheck failed!\n"
else
	echo -e "\nCheck passed!\n"
fi

# reboot the system
#read -t 20 -n 1 -p "Skip the system reboot for this moment? [y/n] " answer
#if [ "\$answer" = "y" ]; then
#	echo -e "\nPlease reboot the system later to take effect."
#else
#	echo -e "\nRebooting the system..."
#	sudo reboot
#fi

exit 0