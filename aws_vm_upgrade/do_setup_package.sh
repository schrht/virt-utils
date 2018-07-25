#!/bin/bash

die() { echo "$@"; exit 1; }

# print title
echo -e "\n=================================================="
echo -e "do_setup_package.sh"
echo -e "==================================================\n"

# install specific packages
sudo yum install -y kernel-tools     || result="failure"
sudo yum install -y kernel-devel     || result="failure"
sudo yum install -y gcc              || result="failure"
sudo yum install -y pciutils         || result="failure"
sudo yum install -y nvme-cli         || result="failure"
sudo yum install -y wget             || result="failure"
sudo yum install -y virt-what        || result="failure"
sudo yum install -y libaio-devel     || result="failure"
sudo yum install -y cryptsetup       || result="failure"
sudo yum install -y lvm2             || result="failure"

[ "$result" = "failure" ] && die "[ERROR] Some packages are failed to install."

exit 0

